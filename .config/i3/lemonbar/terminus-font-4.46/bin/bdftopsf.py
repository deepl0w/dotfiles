#
# Copyright (c) 2017 Dimitar Toshkov Zhekov <dimitar.zhekov@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

import sys
import re

import fnutil
import fnio
import bdf

version = None
exchange = None
output = None

def showHelp():
	sys.stdout.write('' +
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
		'<ss> is always specified as FFFE, although it is stored as FE in PSF2.\n')


def parseArgv(opt, optarg):
	global version
	global exchange
	global output

	if opt in ['-1', '-2']:
		version = int(opt[1:])
	elif opt in ['-g', '--vga']:
		exchange = True
	elif opt == '-G':
		exchange = False
	elif opt in ['-r', '--raw']:
		version = 0
	elif opt == '-o':
		output = optarg
	elif opt == '--help':
		showHelp()
		sys.exit(0)
	elif opt == '--version':
		fnutil.showLicense('bdftopsf.py 1.00, Copyright (C) 2017 Dimitar Toshkov Zhekov\n')
		sys.exit(0)
	else:
		raise Exception('unknown option "' + opt + '", try --help')


def mainProgram(optind):
	global version
	global exchange

	# READ INPUT
	if optind < len(sys.argv) and sys.argv[optind].lower().endswith('.bdf'):
		st = fnio.InputStream(sys.argv[optind])
		optind += 1
	else:
		st = fnio.InputStream(None)

	try:
		font = bdf.Font.read(st)
		st.close()
	except Exception as e:
		raise Exception(st.location() + str(e))

	try:
		if font.xlfd[bdf.XLFD.SPACING] != 'C':
			raise Exception('SPACING "C" required')

		keys = ['width', 'height', 'xoff', 'yoff']

		for char in font.chars:
			for name in keys:
				if getattr(char.bbx, name) != getattr(font.bbx, name):
					raise Exception('char {0}: BBX must be identical to FONTBOUNDINGBOX'.format(char.code))

			if char.code == 65534:
				raise Exception('65534 is not a character, use 65535 for empty position')

		ver1NumChars = len(font.chars) == 256 or len(font.chars) == 512

		if version == None:
			if ver1NumChars and font.bbx.width == 8:
				version = 1
			else:
				version = 2
		elif version == 1:
			if not ver1NumChars:
				raise Exception('-1 requires a font with 256 or 512 characters')

			if font.bbx.width != 8:
				raise Exception('-1 requires a font with width 8')

		vgaNumChars = len(font.chars) >= 224 and len(font.chars) <= 512
		vgaTextSize = font.bbx.width == 8 and font.bbx.height in [8, 14, 16]

		if exchange == None:
			exchange = vgaTextSize and version >= 1 and vgaNumChars and font.chars[0].code == 0x00A3
		elif exchange:
			if not vgaNumChars:
				raise Exception('-g/--vga requires a font with 224...512 characters')

			if not vgaTextSize:
				raise Exception('-g/--vga requires an 8x8, 8x14 or 8x16 font')
	except Exception as e:
		raise Exception(st.fileName + ': ' + str(e))

	# READ EXTRAS
	tables = dict()

	def loadExtra(line):
		words = re.split('\s+', line)

		if len(words) < 2:
			raise Exception('invalid format')

		uni = fnutil.parseHex('unicode', words[0])

		if uni == 0xFFFE:
			raise Exception('FFFE is not a character')

		if not uni in tables:
			tables[uni] = []

		table = tables[uni]

		del words[0]
		for word in words:
			dup = fnutil.parseHex('extra code', word)

			if dup == 0xFFFF:
				raise Exception('FFFF is not a character')

			if not dup in table or 0xFFFE in table:
				tables[uni].append(dup)

	while optind < len(sys.argv):
		st = fnio.InputStream(sys.argv[optind])
		optind += 1

		try:
			st.readLines(loadExtra)
			st.close()
		except Exception as e:
			raise Exception(st.location() + str(e))

	# REMAP
	newChars = font.chars[:]

	if exchange:
		for index in range(0, 32):
			newChars[index] = font.chars[0xC0 + index]
			newChars[0xC0 + index] = font.chars[index]

	# WRITE
	st = fnio.OutputStream(output)

	if st.file.isatty():
		raise Exception('binary output may not be send to a terminal, use -o or redirect/pipe it')

	try:
		# HEADER
		if version == 1:
			st.write8(0x36)
			st.write8(0x04)
			st.write8((len(font.chars) >> 8) + 1)
			st.write8(font.bbx.height)
		elif version == 2:
			st.write32(0x864AB572)
			st.write32(0x00000000)
			st.write32(0x00000020)
			st.write32(0x00000001)
			st.write32(len(font.chars))
			st.write32(len(font.chars[0].data))
			st.write32(font.bbx.height)
			st.write32(font.bbx.width)
		# GLYPHS
		for char in newChars:
			st.write(char.data, None)
		# UNICODES
		if version > 0:
			def writeUnicode(code):
				if version == 1:
					st.write16(code)
				elif code <= 0x7F:
					st.write8(code)
				elif code == 0xFFFE or code == 0xFFFF:
					st.write8(code & 0xFF)
				else:
					if code <= 0x7FF:
						st.write8(0xC0 + (code >> 6))
					else:
						if code <= 0xFFFF:
							st.write8(0xE0 + (code >> 12))
						else:
							st.write8(0xF0 + (code >> 18))
							st.write8(0x80 + ((code >> 12) & 0x3F))

						st.write8(0x80 + ((code >> 6) & 0x3F))

					st.write8(0x80 + (code & 0x3F))

			for char in newChars:
				if char.code != 0xFFFF:
					writeUnicode(char.code)

				if char.code in tables:
					for extra in tables[char.code]:
						writeUnicode(extra)

				writeUnicode(0xFFFF)
		# FINISH
		st.close()
	except Exception as e:
		st.destroy()
		raise Exception(st.fileName + ': ' + str(e))


# STARTUP
fnutil.startCli('bdftopsf.py', parseArgv, 'o', mainProgram)
