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
import copy

import fnutil
import fnio
import bdf

filter = False
output = None

def showHelp():
	sys.stdout.write('' +
		'usage: ucstoany.js [-c] [-o OUTPUT] INPUT REGISTRY ENCODING TABLE...\n' +
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
		'Unlike ucs2any, all TABLE-s form a single subset of the input font.\n')


def parseArgv(opt, optarg):
	global filter
	global output

	if opt in ['-f', '--filter']:
		filter = True
	elif opt == '-o':
		output = optarg
	elif opt == '--help':
		showHelp()
		sys.exit(0)
	elif opt == '--version':
		fnutil.showLicense('ucstoany.py 1.00, Copyright (C) 2017 Dimitar Toshkov Zhekov\n')
		sys.exit(0)
	else:
		raise Exception('unknown option "' + opt + '", try --help')


def mainProgram(optind):
	# NON-OPTIONS
	if len(sys.argv) - optind < 4:
		raise Exception('invalid number of arguments, try --help')

	input = sys.argv[optind]
	st = fnio.InputStream(input)
	registry = sys.argv[optind + 1]
	encoding = sys.argv[optind + 2]
	newCodes = []

	if re.match('^[A-Za-z][\w.:()]*$', registry) == None or re.match('^[\w.:()]+$', encoding) == None:
		raise Exception('invalid registry or encoding')

	# READ INPUT
	try:
		oldFont = bdf.Font.read(st)
		st.close()
	except Exception as e:
		raise Exception(st.location() + str(e))

	# READ TABLES
	optind += 3
	while optind < len(sys.argv):
		st = fnio.InputStream(sys.argv[optind])
		optind += 1

		def loadCode(line):
			newCodes.append(fnutil.parseHex('unicode', line))

		try:
			st.readLines(loadCode)
			st.close()
		except Exception as e:
			raise Exception(st.location() + str(e))

	if not newCodes:
		raise Exception('no characters in the output font')

	# CREATE GLYPHS
	newFont = bdf.Font()
	charMap = {char.code:char for char in oldFont.chars}
	index = 0
	unstart = 0

	if filter:
		unstart = 32 if registry == 'ISO10646' else 1114111

	for code in newCodes:
		if filter and code == 0xFFFF:
			index += 1
			continue

		if code in charMap:
			oldChar = charMap[code]
			uniFFFF = False
		else:
			missing = hex(code)[2:].upper()
			uniFFFF = True

			if code != 0xFFFF:
				raise Exception('{0} does not contain {1}'.format(input, missing))

			if oldFont.defaultCode != None:
				oldChar = charMap[oldFont.defaultCode]
			elif 0xFFFD in charMap:
				oldChar = charMap[0xFFFD]
			else:
				raise Exception('{0} does not contain {1}, and no stub found'.format(input, missing))

		newChar = copy.copy(oldChar)
		newChar.props = oldChar.props.copy()
		newChar.code = code if index >= unstart else index
		index += 1
		newChar.props['ENCODING'] = str(newChar.code)
		newFont.chars.append(newChar)

		if uniFFFF:
			newChar.props['STARTCHAR'] = 'uniFFFF'
		elif oldChar.code == oldFont.defaultCode or (oldChar.code == 0xFFFD and newFont.defaultCode == None):
			newFont.defaultCode = newChar.code

	# CREATE HEADER
	propertyCount = None
	propertyDelta = 0

	for name, value in oldFont.props.items():
		if name == 'FONT':
			newFont.xlfd = oldFont.xlfd[:]
			newFont.xlfd[13] = registry
			newFont.xlfd[14] = encoding
			value = '-'.join(newFont.xlfd)
		elif name == 'STARTPROPERTIES':
			propertyCount = fnutil.parseDec(name, value, 1, 250)
		elif name == 'CHARSET_REGISTRY':
			value = '"' + registry + '"'
		elif name == 'CHARSET_ENCODING':
			value = '"' + encoding + '"'
		elif name == 'DEFAULT_CHAR':
			if newFont.defaultCode != None:
				value = str(newFont.defaultCode)
			else:
				propertyDelta = -1
				continue
		elif name == 'ENDPROPERTIES':
			if propertyCount == None:
				raise Exception(input + ': ENDPROPERTIES without STARTPROPERTIES')

			if newFont.defaultCode != None and not 'DEFAULT_CHAR' in newFont.props:
				newFont.props['DEFAULT_CHAR'] = str(newFont.defaultCode)
				propertyDelta += 1

			newFont.props['STARTPROPERTIES'] = str(propertyCount + propertyDelta)
		elif name == 'CHARS':
			value = str(len(newFont.chars))

		newFont.props[name] = value

	newFont.version = oldFont.version
	newFont.bbx = oldFont.bbx

	# WRITE OUTPUT
	st = fnio.OutputStream(output)

	try:
		newFont.write(st)
		st.close()
	except Exception as e:
		st.destroy()
		raise Exception(st.fileName + ': ' + str(e))


# STARTUP
fnutil.startCli('ucstoany.py', parseArgv, 'o', mainProgram)
