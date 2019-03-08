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

const fnutil = require('./fnutil.js');

// -- BBX --
const WIDTH_MAX = 128;
const HEIGHT_MAX = 256;

class BBX {
	constructor() {
		this.xoff = 0;
		this.yoff = 0;
	}

	parse(name, string) {
		let words = string.split(/\s+/, 5);

		if (words.length !== 4) {
			throw new Error(name + ' must contain 4 values');
		}

		this.width = fnutil.parseDec('width', words[0], 1, WIDTH_MAX);
		this.height = fnutil.parseDec('height', words[1], 1, HEIGHT_MAX);
		this.xoff = fnutil.parseDec('bbxoff', words[2], -WIDTH_MAX, WIDTH_MAX);
		this.yoff = fnutil.parseDec('bbyoff', words[3], -HEIGHT_MAX, HEIGHT_MAX);
	}

	rowSize() {
		return Math.floor((this.width - 1) >> 3) + 1;
	}
}

// -- char/font --
function skipComments(line) {
	// that's how bdftopcf works, though the standard may imply /^COMMENT(\W.*)?$/
	return !line.startsWith('COMMENT');
}

function expect(line, regex, descr) {
	let match = (line !== null) ? line.match(regex) : null;

	if (match === null) {
		throw new Error(descr + ' expected');
	}

	return match;
}

function readExpect(is, regex, descr) {
	let line = is.readLines(skipComments);

	expect(line, regex, descr);
	return line;
}

// -- Char --
class Char {
	constructor() {
		this.props = new Map();
		this.code = null;
		this.bbx = new BBX();
		this.data = null;
	}

	freeze() {
		Object.freeze(this.props);  // does not work ATM
		Object.freeze(this.bbx);
		return Object.freeze(this);
	}

	_read(is) {
		// HEADER
		let line = readExpect(is, /^STARTCHAR\s+\S/, 'STARTCHAR <name>');

		for (;;) {
			let name = line.split(/\s/, 1)[0];
			let value = line.substring(name.length).trimLeft();

			switch (name) {
			case 'ENCODING':
				this.code = fnutil.parseDec(name, value, 0, 1114111);
				break;
			case 'BBX':
				this.bbx.parse(name, value);
				break;
			case '':
				throw new Error('leading space(s) or empty line');
			}

			if (this.props.has(name)) {
				throw new Error('duplicate ' + name);
			}

			this.props.set(name, value);

			if (name === 'BITMAP') {
				break;
			}
			if ((line = is.readLines(skipComments)) === null) {
				throw new Error('BITMAP expected');
			}
		}

		['ENCODING', 'BBX'].forEach(function(name) {
			if (!this.props.has(name)) {
				throw new Error(name + ' required');
			}
		}, this);

		// BITMAP
		let bitmap = '';
		let rowLen = this.bbx.rowSize() * 2;

		for (let y = 0; y < this.bbx.height; y++) {
			line = is.readLines(skipComments);

			if (line === null) {
				throw new Error('bitmap data expected');
			}
			if (line.length === rowLen) {
				bitmap += line;
			} else {
				throw new Error('invalid bitmap length');
			}
		}

		if (bitmap.match(/^[\dA-Fa-f]+$/)) {
			this.data = Buffer.from(bitmap, 'hex');
		} else {
			throw new Error('invalid bitmap data');
		}

		readExpect(is, /^ENDCHAR$/, 'ENDCHAR');
		return this;
	}

	static read(is) {
		return (new Char())._read(is);
	}

	write(os) {
		this.props.forEach(function(value, name) {
			os.writeLine((name + ' ' + value).trimRight());
		});

		let bitmap = this.data.toString('hex').toUpperCase();
		let step = bitmap.length / this.bbx.height;

		for (let index = 0; index < bitmap.length; index += step) {
			os.writeLine(bitmap.substring(index, index + step));
		}

		os.writeLine('ENDCHAR');
	}
}

// -- Font --
const CHARS_MAX = 65536;

class Font {
	constructor() {
		this.props = new Map();
		this.version = 2.1;
		this.xlfd = [];
		this.bbx = new BBX();
		this.chars = [];
		this.defaultCode = null;
	}

	freeze() {
		Object.freeze(this.props);  // does not work ATM
		Object.freeze(this.xlfd);
		Object.freeze(this.bbx);
		Object.freeze(this.chars);
		return Object.freeze(this);
	}

	getAvgWidth() {
		let avgWidth = Math.round(this.chars.reduce((total, char) => total + char.bbx.width, 0) / this.chars.length);

		return Math.min(avgWidth, this.bbx.width);
	}

	_read(is) {
		// HEADER
		let line = is.readLine();
		let match = expect(line, /^STARTFONT\s+(2\.[12])$/, 'STARTFONT 2.1 or 2.2');
		let numChars;

		this.version = parseFloat(match[1]);

		for (;;) {
			let name = line.split(/\s/, 1)[0];
			let value = line.substring(name.length).trimLeft();

			switch (name) {
			case 'FONT':
				this.xlfd = value.split('-', 16);
				if (this.xlfd.length !== 15 || this.xlfd[0] !== '') {
					throw new Error('invalid FONT');
				}
				break;
			case 'FONTBOUNDINGBOX':
				this.bbx.parse(name, value);
				break;
			case 'CHARS':
				numChars = fnutil.parseDec(name, value, 1, CHARS_MAX);
				break;
			case 'DEFAULT_CHAR':
				this.defaultCode = fnutil.parseDec(name, value, 0, 1114111);
				break;
			case '':
				throw new Error('leading space(s) or empty line');
			}

			if (this.props.has(name)) {
				throw new Error('duplicate ' + name);
			}

			this.props.set(name, value);

			if (name === 'CHARS') {
				break;
			}
			if ((line = is.readLines(skipComments)) === null) {
				throw new Error('CHARS expected');
			}
		}

		['FONT', 'FONTBOUNDINGBOX'].forEach(function(name) {
			if (!this.props.has(name)) {
				throw new Error(name + ' required');
			}
		}, this);

		// GLYPHS
		for (let i = 0; i < numChars; i++) {
			this.chars.push(Char.read(is));
		}

		if (this.defaultCode !== null && this.chars.find(char => char.code === this.defaultCode) == null) {
			throw new Error('invalid DEFAULT_CHAR');
		}

		// ENDING
		readExpect(is, /^ENDFONT$/, 'ENDFONT');
		is.readLines(function(garbage) {
			if (garbage.length > 0) {
				throw new Error('garbage after ENDFONT');
			}
		});
		return this;
	}

	static read(is) {
		return (new Font())._read(is);
	}

	write(os) {
		this.props.forEach(function(value, name) {
			os.writeLine((name + ' ' + value).trimRight());
		});

		this.chars.forEach(char => char.write(os));
		os.writeLine('ENDFONT');
	}
}

// -- XLFD --
const XLFD = {
	FOUNDRY:          1,
	FAMILY_NAME:      2,
	WEIGHT_NAME:      3,
	SLANT:            4,
	SETWIDTH_NAME:    5,
	ADD_STYLE_NAME:   6,
	PIXEL_SIZE:       7,
	POINT_SIZE:       8,
	RESOLUTION_X:     9,
	RESOLUTION_Y:     10,
	SPACING:          11,
	AVERAGE_WIDTH:    12,
	CHARSET_REGISTRY: 13,
	CHARSET_ENCODING: 14
};

// EXPORTS
module.exports = Object.freeze({
	BBX,
	Char,
	Font,
	XLFD
});
