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
import codecs
from collections import OrderedDict
from functools import reduce
from enum import IntEnum, unique

import fnutil

# -- BBX --
WIDTH_MAX = 128
HEIGHT_MAX = 256

class BBX:
	def __init__(self):
		self.xoff = 0
		self.yoff = 0


	def parse(self, name, value):
		words = re.split('\s+', value, 4)

		if len(words) != 4:
			raise Exception(name + ' must contain 4 values')

		self.width = fnutil.parseDec('width', words[0], 1, WIDTH_MAX)
		self.height = fnutil.parseDec('height', words[1], 1, HEIGHT_MAX)
		self.xoff = fnutil.parseDec('bbxoff', words[2], -WIDTH_MAX, WIDTH_MAX)
		self.yoff = fnutil.parseDec('bbyoff', words[3], -HEIGHT_MAX, HEIGHT_MAX)


	def rowSize(self):
		return ((self.width - 1) >> 3) + 1


# -- char/font --
def _skipComments(line):
	# that's how bdftopcf works, though the standard may imply ^COMMENT(\W.*)?$
	return not line.startswith('COMMENT')


def _expect(line, regex, descr):
	match = re.match(regex, line) if line != None else None

	if match == None:
		raise Exception(descr + ' expected')

	return match


def _readExpect(st, regex, descr):
	line = st.readLines(_skipComments)
	_expect(line, regex, descr)
	return line


# -- Char --
class Char:
	def __init__(self):
		self.props = OrderedDict()
		self.code = None
		self.bbx = BBX()
		self.data = None


	def _read(self, st):
		# HEADER
		line = _readExpect(st, '^STARTCHAR\s+\S', 'STARTCHAR <name>')

		while True:
			name = re.split('\s', line, 1)[0]
			value = line[len(name):].lstrip()

			if name == 'ENCODING':
				self.code = fnutil.parseDec(name, value, 0, 1114111)
			elif name == 'BBX':
				self.bbx.parse(name, value)
			elif name == '':
				raise Exception('leading space(s) or empty line')

			if name in self.props:
				raise Exception('duplicate ' + name)

			self.props[name] = value

			if name == 'BITMAP':
				break

			line = st.readLines(_skipComments)
			if line == None:
				raise Exception('BITMAP expected')

		for name in ['ENCODING', 'BBX']:
			if not name in self.props:
				raise Exception(name + ' required')

		# BITMAP
		bitmap = ''
		rowLen = self.bbx.rowSize() * 2

		for _ in range(0, self.bbx.height):
			line = st.readLines(_skipComments)

			if line == None:
				raise Exception('bitmap data expected')

			if len(line) == rowLen:
				bitmap += line
			else:
				raise Exception('invalid bitmap length')

		self.data = bytes.fromhex(bitmap)

		_readExpect(st, '^ENDCHAR$', 'ENDCHAR')
		return self


	@staticmethod
	def read(st):
		return Char()._read(st)


	def write(self, st):
		for name, value in self.props.items():
			st.writeLine((name + ' ' + value).rstrip())

		bitmap = codecs.encode(self.data, 'hex').decode('ascii')
		step = int(len(bitmap) / self.bbx.height)

		for index in range(0, len(bitmap), step):
			st.writeLine(bitmap[index:index + step])

		st.writeLine('ENDCHAR')


# -- Font --
CHARS_MAX = 65536

class Font:
	def __init__(self):
		self.props = OrderedDict()
		self.version = 2.1
		self.xlfd = []
		self.bbx = BBX()
		self.chars = []
		self.defaultCode = None


	def getAvgWidth(self):
		avgWidth = round(reduce(lambda total, char: total + char.bbx.width, self.chars, 0)  / len(self.chars))
		return min(avgWidth, self.bbx.width)


	def _read(self, st):
		# HEADER
		line = st.readLine()
		match = _expect(line, '^STARTFONT\s+(2\.[12])$', 'STARTFONT 2.1 or 2.2')
		self.version = float(match.group(1))

		while True:
			name = re.split('\s', line, 1)[0]
			value = line[len(name):].lstrip()

			if name == 'FONT':
				self.xlfd = re.split('-', value, 15)
				if len(self.xlfd) != 15 or self.xlfd[0] != '':
					raise Exception('invalid FONT')
			elif name == 'FONTBOUNDINGBOX':
				self.bbx.parse(name, value)
			elif name == 'CHARS':
				numChars = fnutil.parseDec(name, value, 1, CHARS_MAX)
			elif name == 'DEFAULT_CHAR':
				self.defaultCode = fnutil.parseDec(name, value, 0, 1114111)
			elif name == '':
				raise Exception('leading space(s) or empty line')

			if name in self.props:
				raise Exception('duplicate ' + name)

			self.props[name] = value

			if name == 'CHARS':
				break

			line = st.readLines(_skipComments)
			if line == None:
				raise Exception('CHARS expected')

		for name in ['FONT', 'FONTBOUNDINGBOX']:
			if not name in self.props:
				raise Exception(name + ' required')

		# GLYPHS
		for _ in range(0, numChars):
			self.chars.append(Char.read(st))

		if next((char.code for char in self.chars if char.code == self.defaultCode), None) != self.defaultCode:
			raise Exception('invalid DEFAULT_CHAR')

		# ENDING
		_readExpect(st, '^ENDFONT$', 'ENDFONT')

		def garbageCheck(line):
			if line:
				raise Exception('garbage after ENDFONT')

		st.readLines(garbageCheck)
		return self


	@staticmethod
	def read(st):
		return Font()._read(st)


	def write(self, st):
		for name, value in self.props.items():
			st.writeLine((name + ' ' + value).rstrip())

		for char in self.chars:
			char.write(st)

		st.writeLine('ENDFONT')

# -- XLFD --
@unique
class XLFD(IntEnum):
	FOUNDRY = 1
	FAMILY_NAME = 2
	WEIGHT_NAME = 3
	SLANT = 4
	SETWIDTH_NAME = 5
	ADD_STYLE_NAME = 6
	PIXEL_SIZE = 7
	POINT_SIZE = 8
	RESOLUTION_X = 9
	RESOLUTION_Y = 10
	SPACING = 11
	AVERAGE_WIDTH = 12
	CHARSET_REGISTRY = 13
	CHARSET_ENCODING = 14
