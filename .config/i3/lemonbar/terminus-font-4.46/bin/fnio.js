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

// will do for now

'use strict';

const fs = require('fs');
const util = require('util');

// -- LineReader --
const BLOCK_SIZE = 4096;
const LINE_ABSMAX = 512;

class LineReader {
	constructor(fd) {
		this.fd = fd;
		this.offset = 0;
		this.bytes = 0;
		this.line = 0;
		this.buffer = Buffer.alloc(LINE_ABSMAX + BLOCK_SIZE);
		this.verify = Buffer.alloc(LINE_ABSMAX);
	}

	createLine(final) {
		this.line++;

		for (var offset = final - 1; offset >= this.offset; offset--) {
			if (this.buffer[offset] >= 0x80) {
				throw new Error('non-ascii character(s)');
			}
		}

		this.offset = final;
		return this.buffer.toString('ascii', offset + 1, final).trimRight();
	}

	readLine() {
		do {
			let final;

			for (final = this.offset; final < this.bytes; final++) {
				if (this.buffer[final] === 0x0A) {
					if (final - this.offset < LINE_ABSMAX) {
						return this.createLine(final + 1);
					}
					break;
				}
			}

			if (final - this.offset >= LINE_ABSMAX) {
				this.line++;
				throw new Error('line too long');
			}

			if (this.bytes > LINE_ABSMAX) {
				this.buffer.copy(this.buffer, 0, this.offset, this.bytes);
				this.bytes -= this.offset;
				this.offset = 0;
			}

			try {
				var count = fs.readSync(this.fd, this.buffer, this.bytes, BLOCK_SIZE);

				this.bytes += count;
			} catch (e) {
				if (e.code === 'EOF') {
					break;
				} else if (e.code === 'EAGAIN') {
					continue;
				} else {
					throw e;
				}
			}
		} while (count > 0);

		if (this.bytes > this.offset) {
			return this.createLine(this.bytes);
		}

		this.line = 'EOF';
		return null;
	}

	readLines(callback) {
		do {
			var line = this.readLine();
		} while (line !== null && !callback(line));

		return line;
	}
}

// -- InputStream --
class InputStream extends LineReader {
	constructor(fileName) {
		super(fileName == null ? process.stdin.fd : fs.openSync(fileName, 'r'));
		this.fileName = fileName || '<stdin>';
		this.locationFormat = '%s:%s: ';
	}

	close() {
		this.locationFormat = '%s: ';
		fs.closeSync(this.fd);
	}

	location() {
		return util.format(this.locationFormat, this.fileName, this.line.toString());
	}
}

// -- ByteWriter --
class ByteWriter {
	constructor(fd) {
		this.fd = fd;
		this.fbbuf = Buffer.alloc(4);
	}

	write(buffer, size) {
		fs.writeSync(this.fd, buffer, 0, size || buffer.length);
	}

	write8(value) {
		this.fbbuf.writeUInt8(value, 0);
		fs.writeSync(this.fd, this.fbbuf, 0, 1);
	}

	write16(value) {
		this.fbbuf.writeUInt16LE(value, 0);
		fs.writeSync(this.fd, this.fbbuf, 0, 2);
	}

	write32(value) {
		this.fbbuf.writeUInt32LE(value, 0);
		fs.writeSync(this.fd, this.fbbuf, 0, 4);
	}
}

// -- OutputStream --
class OutputStream extends ByteWriter {
	constructor(fileName) {
		super(fileName == null ? process.stdout.fd : fs.openSync(fileName, 'w'));
		this.fileName = fileName || '<stdout>';
		this.closeAttempt = false;
	}

	close() {
		this.closeAttempt = true;
		fs.closeSync(this.fd);
	}

	destroy() {
		if (this.fd !== process.stdout.fd) {
			if (!this.closeAttempt) {
				try {
					fs.closeSync(this.fd);
				} catch (e) {
					// nop
				}
			}

			try {
				fs.unlinkSync(this.fileName);
			} catch (e) {
				// nop
			}
		}
	}

	writeLine(string) {
		fs.writeSync(this.fd, string + '\n', null, 'ascii');
	}

	writeZStr(string, numZeros) {
		fs.writeSync(this.fd, string, null, 'ascii');

		if (numZeros > 0) {
			this.write(Buffer.alloc(numZeros));
		}
	}
}

// EXPORTS
module.exports = Object.freeze({
	InputStream,
	OutputStream
});
