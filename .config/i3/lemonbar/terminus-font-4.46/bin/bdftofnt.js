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

var charset = null;
var minChar = null;
var fntFamily = 0;
var output = null;

function showHelp() {
	process.stdout.write('' +
		'usage: bdftofnt.js [-c CHARSET] [-m MINCHAR] [-f FAMILY] [-o OUTPUT] [INPUT]\n' +
		'Convert a BDF font to Windows FNT\n' +
		'\n' +
		'  -c CHARSET   fnt character set (default = 0, see wingdi.h ..._CHARSET)\n' +
		'  -m MINCHAR   fnt minimum character code (8-bit CP decimal, not unicode)\n' +
		'  -f FAMILY    fnt family: DontCare, Roman, Swiss, Modern or Decorative\n' +
		'  -o OUTPUT    output file (default = stdout)\n' +
		'  --help       display this help and exit\n' +
		'  --version    display the program version and license, and exit\n' +
		'  --excstk     display the exception stack on error\n' +
		'\n' +
		'The input must be a BDF font encoded in the unicode range. All characters\n' +
		'must have identical height and yoff.\n'
	);
}

function parseArgv(opt, optarg) {
	const FNT_FAMILIES = [ 'DontCare', 'Roman', 'Swiss', 'Modern', 'Decorative' ];

	switch (opt) {
	case '-c':
		charset = fnutil.parseDec('charset', optarg, 0, 255);
		break;
	case '-m':
		minChar = fnutil.parseDec('minchar', optarg, 0, 255);
		break;
	case '-f':
		fntFamily = FNT_FAMILIES.indexOf(optarg);

		if (fntFamily === -1) {
			throw new Error('invalid fnt family');
		}
		break;
	case '-o':
		output = optarg;
		break;
	case '--help':
		showHelp();
		process.exit(0);
		break;
	case '--version':
		fnutil.showLicense('bdftofnt.js 1.00, Copyright (C) 2017 Dimitar Toshkov Zhekov\n');
		process.exit(0);
		break;
	default :
		throw new Error('unknown option "' + opt + '", try --help');
	}
}

function mainProgram(optind) {
	const WIN_FONTHEADERSIZE = 118;

	// READ INPUT
	if (process.argv.length - optind > 1) {
		throw new Error('invalid number of arguments, try --help');
	}

	let is = new fnio.InputStream(process.argv[optind]);

	try {
		var font = bdf.Font.read(is).freeze();
		is.close();
	} catch (e) {
		e.message = is.location() + e.message;
		throw e;
	}

	// PRE-COMPUTE
	if (charset === null) {
		let encoding = font.xlfd[bdf.XLFD.CHARSET_ENCODING];

		if (encoding.toLowerCase().match(/(cp)?125[0-8]/)) {
			const FNT_CHARSETS = [238, 204, 0, 161, 162, 177, 178, 186, 163];

			charset = FNT_CHARSETS[parseInt(encoding.substring(encoding.length - 1), 10)];
		} else {
			charset = 255;
		}
	}

	try {
		// CHECK INPUT
		if (font.bbx.yoff > 0 || font.bbx.height + font.bbx.yoff < 0) {
			throw new Error('FONTBOUNDINGBOX yoff must be between 0 and -' + font.bbx.height.toString());
		}
		font.chars.forEach(function(char) {
			let prefix = util.format('char %d: ', char.code);

			if (char.bbx.width > font.bbx.width) {
				throw new Error(prefix + 'BBX width exceeds FONTBOUNDINGBOX');
			}
			if (char.bbx.height !== font.bbx.height || char.bbx.yoff !== font.bbx.yoff) {
				throw new Error(prefix + 'BBX height and yoff must be identical to FONTBOUNDINGBOX');
			}
		});

		const numChars = font.chars.length;

		if (numChars > 256) {
			throw new Error('too many characters, the maximum is 256');
		}
		if (minChar === null) {
			if (numChars === 192 || numChars === 256) {
				minChar = 256 - numChars;
			} else {
				minChar = font.chars[0].code;
			}
		}

		var maxChar = minChar + numChars - 1;

		if (maxChar >= 256) {
			throw new Error('the maximum char is too big, (re)specify -m');
		}

		// HEADER
		var vTell = WIN_FONTHEADERSIZE + (numChars + 1) * 4;
		var bitsOffset = vTell;
		var cTable = [];
		var widthBytes = 0;

		// CTABLE/GLYPHS
		font.chars.forEach(function(char) {
			let rowSize = char.bbx.rowSize();

			cTable.push(char.bbx.width);
			cTable.push(vTell);
			vTell += rowSize * font.bbx.height;
			widthBytes += rowSize;
		});

		if (vTell > 0xFFFF) {
			throw new Error('too much character data');
		}
		// SENTINEL
		var sentinel = 2 - widthBytes % 2;

		cTable.push(sentinel * 8);
		cTable.push(vTell);
		vTell += sentinel * font.bbx.height;
		widthBytes += sentinel;

		if (widthBytes > 0xFFFF) {
			throw new Error('the total character width is too big');
		}
	} catch (e) {
		e.message = is.fileName + ': ' + e.message;
		throw e;
	}

	// WRITE
	let os = new fnio.OutputStream(output);

	if (tty.isatty(os.fd)) {
		throw new Error('binary output may not be send to a terminal, use -o or redirect/pipe it');
	}

	function intEql(index, value) {
		return font.xlfd[index].toUpperCase() === value ? 1 : 0;
	}

	try {
		// HEADER
		let family = font.xlfd[bdf.XLFD.FAMILY_NAME];
		let copyright = font.props.get('COPYRIGHT');
		let proportional = intEql(bdf.XLFD.SPACING, 'P');

		copyright = (copyright != null) ? fnutil.unQuote(copyright).substring(0, 60) : '';
		os.write16(0x0200);                                            // font version
		os.write32(vTell + family.length + 1);                         // total size
		os.writeZStr(copyright, 60 - copyright.length);
		os.write16(0);                                                 // gdi, device type
		os.write16(Math.round(font.bbx.height * 72 / 96));
		os.write16(96);                                                // vertical resolution
		os.write16(96);                                                // horizontal resolution
		os.write16(font.bbx.height + font.bbx.yoff);
		os.write16(0);                                                 // internal leading
		os.write16(0);                                                 // external leading
		os.write8(intEql(bdf.XLFD.SLANT, 'I'));
		os.write8(0);                                                  // underline
		os.write8(0);                                                  // strikeout
		os.write16(400 + 300 * intEql(bdf.XLFD.WEIGHT_NAME, 'BOLD'));
		os.write8(charset);
		os.write16(font.bbx.width * (1 - proportional));
		os.write16(font.bbx.height);
		os.write8((fntFamily << 4) + proportional);
		os.write16(font.getAvgWidth());
		os.write16(font.bbx.width);                                    // max width
		os.write8(minChar);
		os.write8(maxChar);

		let defaultIndex = maxChar - minChar;
		let breakIndex = 0;

		if (font.defaultCode !== null) {
			defaultIndex = font.chars.findIndex(char => char.code === font.defaultCode);
		}

		if (minChar <= 0x20 && maxChar >= 0x20) {
			breakIndex = 0x20 - minChar;
		}

		os.write8(defaultIndex);
		os.write8(breakIndex);
		os.write16(widthBytes);
		os.write32(0);           // device name
		os.write32(vTell);
		os.write32(0);           // gdi bits pointer
		os.write32(bitsOffset);
		os.write8(0);            // reserved
		// CTABLE
		cTable.forEach(value => os.write16(value));
		// GLYPHS
		let data = new Buffer(font.bbx.rowSize() * font.bbx.height);

		font.chars.forEach(function(char) {
			let rowSize = char.bbx.rowSize();
			let counter = 0;
			// MS coordinates
			for (let n = 0; n < rowSize; n++) {
				for (let y = 0; y < font.bbx.height; y++) {
					data[counter++] = char.data[rowSize * y + n];
				}
			}
			os.write(data, counter);
		});
		os.write(Buffer.alloc(sentinel * font.bbx.height));
		// FAMILY
		os.writeZStr(family, 1);
		os.close();
	} catch (e) {
		os.destroy();
		e.message = os.fileName + ': ' + e.message;
		throw e;
	}
}

// STARTUP
fnutil.startCli('bdftofnt.js', parseArgv, 'cmfo', mainProgram);
