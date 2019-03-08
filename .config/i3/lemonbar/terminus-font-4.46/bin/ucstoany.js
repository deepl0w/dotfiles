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
const fnutil = require('./fnutil.js');
const fnio = require('./fnio.js');
const bdf = require('./bdf.js');

var filter = false;
var output;

function showHelp() {
	process.stdout.write('' +
		'usage: ucstoany.js [-f] [-o OUTPUT] INPUT REGISTRY ENCODING TABLE...\n' +
		'Generate a BDF font subset.\n' +
		'\n' +
		'  -f, --filter   discard characters with unicode FFFF; with registry\n' +
		'                 ISO10646, encode the first 32 characters with their\n' +
		'                 indexes, otherwise encode all characters with indexes\n' +
		'  -o OUTPUT      output file (default = stdout)\n' +
		'  INPUT          an unicode-encoded BDF font\n' +
		'  TABLE          text file, one hexadecimal unicode per line\n' +
		'  --help         display this help and exit\n' +
		'  --version      display the program version and license, and exit\n' +
		'  --excstk       display the exception stack on error\n' +
		'\n' +
		'The input must be a BDF font encoded in the unicode range.\n' +
		'Unlike ucs2any, all TABLE-s form a single subset of the input font.\n'
	);
}

function parseArgv(opt, optarg) {
	switch (opt) {
	case '-f':
	case '--filter':
		filter = true;
		break;
	case '-o':
		output = optarg;
		return true;
	case '--help':
		showHelp();
		process.exit(0);
		break;
	case '--version':
		fnutil.showLicense('ucstoany.js 1.00, Copyright (C) 2017 Dimitar Toshkov Zhekov\n');
		process.exit(0);
		break;
	default :
		throw new Error('unknown option "' + opt + '", try --help');
	}

	return false;
}

function mainProgram(optind) {
	// NON-OPTIONS
	if (process.argv.length - optind < 4) {
		throw new Error('invalid number of arguments, try --help');
	}

	let input = process.argv[optind];
	let is = new fnio.InputStream(input);
	let registry = process.argv[optind + 1];
	let encoding = process.argv[optind + 2];
	let newCodes = [];

	if (!registry.match(/^[A-Za-z][\w.:()]*$/) || !encoding.match(/^[\w.:()]+$/)) {
		throw new Error(util.format('invalid registry "%s" or encoding "%s"', registry, encoding));
	}

	// READ INPUT
	try {
		var oldFont = bdf.Font.read(is).freeze();
		is.close();
	} catch (e) {
		e.message = is.location() + e.message;
		throw e;
	}

	// READ TABLES
	for (optind += 3; optind < process.argv.length; optind++) {
		is = new fnio.InputStream(process.argv[optind]);

		try {
			is.readLines(function(line) {
				newCodes.push(fnutil.parseHex('unicode', line));
			});
			is.close();
		} catch (e) {
			e.message = is.location() + e.message;
			throw e;
		}
	}

	if (newCodes.length === 0) {
		throw new Error('no characters in the output font');
	}

	// CREATE GLYPHS
	let newFont = new bdf.Font();
	let charMap = [];
	let index = 0;
	let unstart = 0;

	if (filter) {
		unstart = (registry === 'ISO10646') ? 32 : unstart = 1114111;
	}

	// bsearch written in js is not faster for 5K characters
	oldFont.chars.forEach(function(char) {
		charMap[char.code] = char;
	});

	newCodes.forEach(function(code) {
		let oldChar = charMap[code];
		let uniFFFF = (oldChar == null);

		if (filter && code === 0xFFFF) {
			index++;
			return;
		}

		if (uniFFFF) {
			let missing = code.toString(16).toUpperCase();

			if (code !== 0xFFFF) {
				throw new Error(util.format('%s does not contain %s', input, missing));
			}

			if (oldFont.defaultCode !== null) {
				oldChar = charMap[oldFont.defaultCode];
			} else {
				oldChar = charMap[0xFFFD];

				if (oldChar == null) {
					throw new Error(util.format('%s does not contain %s, and no stub found', input, missing));
				}
			}
		}

		let newChar = new bdf.Char();

		oldChar = oldChar.freeze();
		newChar.props = new Map(oldChar.props);
		newChar.code = index >= unstart ? code : index;
		index++;
		newChar.props.set('ENCODING', newChar.code.toString());
		newChar.bbx = oldChar.bbx;
		newChar.data = oldChar.data;
		newFont.chars.push(newChar);

		if (uniFFFF) {
			newChar.props.set('STARTCHAR', 'uniFFFF');
		} else if (oldChar.code === oldFont.defaultCode || (oldChar.code === 0xFFFD && newFont.defaultCode === null)) {
			newFont.defaultCode = newChar.code;
		}
	});

	// CREATE HEADER
	let propertyCount = null;
	let propertyDelta = 0;

	oldFont.props.forEach(function(value, name) {
		switch (name) {
		case 'FONT':
			newFont.xlfd = oldFont.xlfd.slice();
			newFont.xlfd[13] = registry;
			newFont.xlfd[14] = encoding;
			value = newFont.xlfd.join('-');
			break;
		case 'STARTPROPERTIES':
			propertyCount = fnutil.parseDec(name, value, 1, 250);
			break;
		case 'CHARSET_REGISTRY':
			value = '"' + registry + '"';
			break;
		case 'CHARSET_ENCODING':
			value = '"' + encoding + '"';
			break;
		case 'DEFAULT_CHAR':
			if (newFont.defaultCode !== null) {
				value = newFont.defaultCode.toString();
			} else {
				propertyDelta -= 1;
				return;
			}
			break;
		case 'ENDPROPERTIES':
			if (propertyCount === null) {
				throw new Error(input + ': ENDPROPERTIES without STARTPROPERTIES');
			}
			if (newFont.defaultCode !== null && !newFont.props.has('DEFAULT_CHAR')) {
				newFont.props.set('DEFAULT_CHAR', newFont.defaultCode.toString());
				propertyDelta += 1;
			}
			newFont.props.set('STARTPROPERTIES', (propertyCount + propertyDelta).toString());
			break;
		case 'CHARS':
			value = newFont.chars.length.toString();
			break;
		}
		newFont.props.set(name, value);
	});
	newFont.version = oldFont.version;
	newFont.bbx = oldFont.bbx;

	// WRITE OUTPUT
	let os = new fnio.OutputStream(output);

	try {
		newFont.write(os);
		os.close();
	} catch (e) {
		os.destroy();
		e.message = os.fileName + ': ' + e.message;
		throw e;
	}
}

// STARTUP
fnutil.startCli('ucstoany.js', parseArgv, 'o', mainProgram);
