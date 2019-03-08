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

import re
import sys

import fnutil
import fnio
import bdf

charset = None
minChar = None
fntFamily = 0
output = None

def showHelp():
	sys.stdout.write('' +
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
		'must have identical height and yoff.\n')


def parseArgv(opt, optarg):
	FNT_FAMILIES = [ 'DontCare', 'Roman', 'Swiss', 'Modern', 'Decorative' ]

	global charset
	global minChar
	global fntFamily
	global output

	if opt == '-c':
		charset = fnutil.parseDec('charset', optarg, 0, 255)
	elif opt == '-m':
		minChar = fnutil.parseDec('minchar', optarg, 0, 255)
	elif opt == '-f':
		if optarg in FNT_FAMILIES:
			fntFamily = FNT_FAMILIES.index(optarg)
		else:
			raise Exception('invalid fnt family')
	elif opt == '-o':
		output = optarg
	elif opt == '--help':
		showHelp()
		sys.exit(0)
	elif opt == '--version':
		fnutil.showLicense('bdftofnt.py 1.00, Copyright (C) 2017 Dimitar Toshkov Zhekov\n')
		sys.exit(0)
	else:
		raise Exception('unknown option "' + opt + '", try --help')


def mainProgram(optind):
	WIN_FONTHEADERSIZE = 118

	global charset
	global minChar

	# READ INPUT
	if len(sys.argv) - optind > 1:
		raise Exception('invalid number of arguments, try --help')

	st = fnio.InputStream(sys.argv[optind] if optind < len(sys.argv) else None)

	try:
		font = bdf.Font.read(st)
		st.close()
	except Exception as e:
		raise Exception(st.location() + str(e))

	# PRE-COMPUTE
	if charset == None:
		encoding = font.xlfd[bdf.XLFD.CHARSET_ENCODING]

		if re.match('(cp)?125[0-8]', encoding.lower()):
			FNT_CHARSETS = [238, 204, 0, 161, 162, 177, 178, 186, 163]
			charset = FNT_CHARSETS[int(encoding[-1:])]
		else:
			charset = 255

	try:
		# CHECK INPUT
		if font.bbx.yoff > 0 or font.bbx.height + font.bbx.yoff < 0:
			raise Exception('FONTBOUNDINGBOX yoff must be between 0 and -' + str(font.bbx.height))

		for char in font.chars:
			prefix = 'char {0}: '.format(char.code)

			if char.bbx.width > font.bbx.width:
				raise Exception(prefix + 'BBX width exceeds FONTBOUNDINGBOX')

			if char.bbx.height != font.bbx.height or char.bbx.yoff != font.bbx.yoff:
				raise Exception(prefix + 'BBX height and yoff must be identical to FONTBOUNDINGBOX')

		numChars = len(font.chars)

		if numChars > 256:
			raise Exception('too many characters, the maximum is 256')

		if minChar == None:
			if numChars == 192 or numChars == 256:
				minChar = 256 - numChars
			else:
				minChar = font.chars[0].code

		maxChar = minChar + numChars - 1

		if maxChar >= 256:
			raise Exception('the maximum char is too big, (re)specify -m')

		# HEADER
		vTell = WIN_FONTHEADERSIZE + (numChars + 1) * 4
		bitsOffset = vTell
		cTable = []
		widthBytes = 0

		# CTABLE/GLYPHS
		for char in font.chars:
			rowSize = char.bbx.rowSize()

			cTable.append(char.bbx.width)
			cTable.append(vTell)
			vTell += rowSize * font.bbx.height
			widthBytes += rowSize

		if vTell > 0xFFFF:
			raise Exception('too much character data')

		# SENTINEL
		sentinel = 2 - widthBytes % 2
		cTable.append(sentinel * 8)
		cTable.append(vTell)
		vTell += sentinel * font.bbx.height
		widthBytes += sentinel

		if widthBytes > 0xFFFF:
			raise Exception('the total character width is too big')

	except Exception as e:
		raise Exception(st.fileName + str(e))

	# WRITE
	st = fnio.OutputStream(output)

	if st.file.isatty():
		raise Exception('binary output may not be send to a terminal, use -o or redirect/pipe it')

	def IntEql(index, value):
		return 1 if font.xlfd[index].upper() == value else 0

	try:
		# HEADER
		family = font.xlfd[bdf.XLFD.FAMILY_NAME]
		copyright = fnutil.unQuote(font.props['COPYRIGHT'])[:60] if 'COPYRIGHT' in font.props else ''
		proportional = IntEql(bdf.XLFD.SPACING, 'P')

		st.write16(0x0200)                                            # font version
		st.write32(vTell + len(family) + 1)                           # total size
		st.writeZStr(copyright, 60 - len(copyright))
		st.write16(0)                                                 # gdi, device type
		st.write16(round(font.bbx.height * 72 / 96))
		st.write16(96)                                                # vertical resolution
		st.write16(96)                                                # horizontal resolution
		st.write16(font.bbx.height + font.bbx.yoff)
		st.write16(0)                                                 # internal leading
		st.write16(0)                                                 # external leading
		st.write8(IntEql(bdf.XLFD.SLANT, 'I'))
		st.write8(0)                                                  # underline
		st.write8(0)                                                  # strikeout
		st.write16(400 + 300 * IntEql(bdf.XLFD.WEIGHT_NAME, 'BOLD'))
		st.write8(charset)
		st.write16(font.bbx.width * (1 - proportional))
		st.write16(font.bbx.height)
		st.write8((fntFamily << 4) + proportional)
		st.write16(font.getAvgWidth())
		st.write16(font.bbx.width)                                    # max width
		st.write8(minChar)
		st.write8(maxChar)

		defaultIndex = maxChar - minChar
		breakIndex = 0

		if font.defaultCode != None:
			defaultIndex = next(index for index, char in enumerate(font.chars) if char.code == font.defaultCode)

		if minChar <= 0x20 and maxChar >= 0x20:
			breakIndex = 0x20 - minChar

		st.write8(defaultIndex)
		st.write8(breakIndex)
		st.write16(widthBytes)
		st.write32(0)           # device name
		st.write32(vTell)
		st.write32(0)           # gdi bits pointer
		st.write32(bitsOffset)
		st.write8(0)            # reserved
		# CTABLE
		for value in cTable:
			st.write16(value)
		# GLYPHS
		data = bytearray(font.bbx.rowSize() * font.bbx.height)

		for char in font.chars:
			rowSize = char.bbx.rowSize()
			counter = 0
			# MS coordinates
			for n in range(0, rowSize):
				for y in range(0, font.bbx.height):
					data[counter] = char.data[rowSize * y + n]
					counter += 1
			st.write(data, counter)
		st.write(bytes(sentinel * font.bbx.height))
		# FAMILY
		st.writeZStr(family, 1)
		st.close()
	except Exception as e:
		st.destroy()
		raise Exception(st.fileName + str(e))


# STARTUP
fnutil.startCli('bdftofnt.py', parseArgv, 'cmfo', mainProgram)
