//
// Copyright (c) 2017 Dimitar Toshkov Zhekov <dimitar.zhekov@gmail.com>
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation; either version 2 of
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//

'use strict';

const util = require('util');
const tty = require('tty');

const fnutil = require('./fnutil.js');
const fnio = require('./fnio.js');
const bdf = require('./bdf.js');

var version = null;
var exchange = null;
var output = null;

function showHelp() {
	process.stdout.write('' +
		'usage: bdftopsf.js [-1|-2|-r] [-g|-G] [-o OUTPUT] [INPUT] [TABLE...]\n' +
		'Convert a BDF font to PC Screen Font or raw font\n' +
		'\n' +
		'  -1, -2      write a PSF version 1 or 2 font (default = 1 if possible)\n' +
		'  -r, --raw   write a RAW font\n' +
		'  -g, --vga   exchange the characters at positions 0...31 with these at\n' +
		'              192...223 (default for VGA text mode compliant PSF fonts\n' +
		'              with 224 to 512 characters starting with unicode 00A3)\n' +
		'  -G          do not exchange characters 0...31 and 192...223\n' +
		'  -o OUTPUT   output file (default = stdout)\n' +
		'  --help      display this help and exit\n' +
		'  --version   display the program version and license, and exit\n' +
		'  --excstk    display the exception stack on error\n' +
		'\n' +
		'The input must be an unicode-encoded BDF font with constant spacing.\n' +
		'\n' +
		'The tables are text files with two or more hexadecimal unicodes per line:\n' +
		'a character code from the BDF, and extra code(s) for it. All extra codes\n' +
		'are stored sequentially in the PSF unicode table for their character.\n' +
		'<ss> is always specified as FFFE, although it is stored as FE in PSF2.\n'
	);
}

function parseArgv(opt, optarg) {
	switch (opt) {
	case '-1':
	case '-2':
		version = parseInt(opt.substring(1));
		break;
	case '-g':
	case '--vga':
		exchange = true;
		break;
	case '-G':
		exchange = false;
		break;
	case '-r':
	case '--raw':
		version = 0;
		break;
	case '-o':
		output = optarg;
		break;
	case '--help':
		showHelp();
		process.exit(0);
		break;
	case '--version':
		fnutil.showLicense('bdftopsf.js 1.00, Copyright (C) 2017 Dimitar Toshkov Zhekov\n');
		process.exit(0);
		break;
	default :
		throw new Error('unknown option "' + opt + '", try --help');
	}
}

function mainProgram(optind) {
	// READ INPUT
	let is;

	if (optind < process.argv.length && process.argv[optind].toLowerCase().endsWith('.bdf')) {
		is = new fnio.InputStream(process.argv[optind++]);
	} else {
		is = new fnio.InputStream(null);
	}

	try {
		var font = bdf.Font.read(is).freeze();
		is.close();
	} catch (e) {
		e.message = is.location() + e.message;
		throw e;
	}

	// CHECK INPUT
	try {
		if (font.xlfd[bdf.XLFD.SPACING] !== 'C') {
			throw new Error('SPACING "C" required');
		}

		const keys = ['width', 'height', 'xoff', 'yoff'];

		font.chars.forEach(function(char) {
			keys.forEach(function(key) {
				if (char.bbx[key] !== font.bbx[key]) {
					throw new Error(util.format('char %d: BBX must be identical to FONTBOUNDINGBOX', char.code));
				}
			});

			if (char.code === 65534) {
				throw new Error('65534 is not a character, use 65535 for empty position');
			}
		});

		let ver1NumChars = (font.chars.length === 256 || font.chars.length === 512);

		if (version === null) {
			version = ver1NumChars && font.bbx.width === 8 ? 1 : 2;
		} else if (version === 1) {
			if (!ver1NumChars) {
				throw new Error('-1 requires a font with 256 or 512 characters');
			}
			if (font.bbx.width !== 8) {
				throw new Error('-1 requires a font with width 8');
			}
		}

		let vgaNumChars = font.chars.length >= 224 && font.chars.length <= 512;
		let vgaTextSize = font.bbx.width === 8 && [8, 14, 16].indexOf(font.bbx.height) !== -1;

		if (exchange === null) {
			exchange = vgaTextSize && version >= 1 && vgaNumChars && font.chars[0].code === 0x00A3;
		} else if (exchange === true) {
			if (!vgaNumChars) {
				throw new Error('-g/--vga requires a font with 224...512 characters');
			}
			if (!vgaTextSize) {
				throw new Error('-g/--vga requires an 8x8, 8x14 or 8x16 font');
			}
		}
	} catch (e) {
		e.message = is.fileName + ': ' + e.message;
		throw e;
	}

	// READ EXTRAS
	let tables = [];

	function loadExtra(line) {
		let words = line.split(/\s+/);

		if (words.length < 2) {
			throw new Error('invalid format');
		}

		let uni = fnutil.parseHex('unicode', words[0]);
		let table = tables[uni];

		if (uni === 0xFFFE) {
			throw new Error('FFFE is not a character');
		}
		if (table == null) {
			table = tables[uni] = [];
		}

		words.shift();
		words.forEach(function(word) {
			let dup = fnutil.parseHex('extra code', word);

			if (dup === 0xFFFF) {
				throw new Error('FFFF is not a character');
			}

			if (table.indexOf(dup) === -1 || table.indexOf(0xFFFE) !== -1) {
				table.push(dup);
			}
		});
	}

	for (; optind < process.argv.length; optind++) {
		is = new fnio.InputStream(process.argv[optind]);

		try {
			is.readLines(loadExtra);
			is.close();
		} catch (e) {
			e.message = is.location() + e.message;
			throw e;
		}
	}

	// REMAP
	let newChars = font.chars.map(char => char);

	if (exchange) {
		for (let index = 0; index < 32; index++) {
			newChars[index] = font.chars[0xC0 + index];
			newChars[0xC0 + index] = font.chars[index];
		}
	}

	// WRITE
	let os = new fnio.OutputStream(output);

	if (tty.isatty(os.fd)) {
		throw new Error('binary output may not be send to a terminal, use -o or redirect/pipe it');
	}

	try {
		// HEADER
		if (version === 1) {
			os.write8(0x36);
			os.write8(0x04);
			os.write8((font.chars.length >> 8) + 1);
			os.write8(font.bbx.height);
		} else if (version === 2) {
			os.write32(0x864AB572);
			os.write32(0x00000000);
			os.write32(0x00000020);
			os.write32(0x00000001);
			os.write32(font.chars.length);
			os.write32(font.chars[0].data.length);
			os.write32(font.bbx.height);
			os.write32(font.bbx.width);
		}
		// GLYPHS
		newChars.forEach(char => os.write(char.data));
		// UNICODES
		if (version > 0) {
			let writeUnicode = function(code) {
				if (version === 1) {
					os.write16(code);
				} else if (code <= 0x7F) {
					os.write8(code);
				} else if (code === 0xFFFE || code === 0xFFFF) {
					os.write8(code & 0xFF);
				} else {
					if (code <= 0x7FF) {
						os.write8(0xC0 + (code >> 6));
					} else {
						if (code <= 0xFFFF) {
							os.write8(0xE0 + (code >> 12));
						} else {
							os.write8(0xF0 + (code >> 18));
							os.write8(0x80 + ((code >> 12) & 0x3F));
						}
						os.write8(0x80 + ((code >> 6) & 0x3F));
					}
					os.write8(0x80 + (code & 0x3F));
				}
			};

			newChars.forEach(function(char) {
				if (char.code !== 0xFFFF) {
					writeUnicode(char.code);
				}

				if (tables[char.code] != null) {
					tables[char.code].forEach(extra => writeUnicode(extra));
				}

				writeUnicode(0xFFFF);
			});
		}
		// FINISH
		os.close();
	} catch (e) {
		os.destroy();
		e.message = os.fileName + ': ' + e.message;
		throw e;
	}
}

// STARTUP
fnutil.startCli('bdftopsf.js', parseArgv, 'o', mainProgram);
