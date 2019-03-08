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

# will do for now

import struct
import sys
import os

# -- InputStream --
LINE_ABSMAX = 512

class InputStream:
	def __init__(self, fileName):
		if fileName == None:
			self.fileName = '<stdin>'
			self.file = sys.stdin.buffer
		else:
			self.fileName = fileName
			self.file = open(fileName, 'rb')

		self.line = 0
		self.locationFormat = '{0}:{1}: '


	def close(self):
		self.locationFormat = '{0}: '
		self.file.close()


	def location(self):
		return self.locationFormat.format(self.fileName, str(self.line))


	def readLine(self):
		line = self.file.readline(LINE_ABSMAX + 1)

		if line:
			self.line += 1

			if len(line) > LINE_ABSMAX:
				raise Exception('line too long')

			return str(line, 'ascii').rstrip()

		self.line = 'EOF'
		return None


	def readLines(self, callback):
		while True:
			line = self.readLine()

			if line == None or callback(line):
				break

		return line


# -- ByteWriter --
class _ByteWriter:
	def __init__(self, file):
		self.file = file


	def write(self, buffer, size = None):
		self.file.write(buffer[:size])


	def write8(self, value):
		self.file.write(struct.pack('B', value))


	def write16(self, value):
		self.file.write(struct.pack('<H', value))


	def write32(self, value):
		self.file.write(struct.pack('<L', value))


# -- OutputStream --
class OutputStream(_ByteWriter):
	def __init__(self, fileName):
		if fileName == None:
			self.fileName = '<stdout>'
			_ByteWriter.__init__(self, sys.stdout.buffer)
		else:
			self.fileName = fileName
			_ByteWriter.__init__(self, open(fileName, 'wb'))

		self.closeAttempt = False


	def close(self):
		self.closeAttempt = True
		self.file.close()


	def destroy(self):
		if self.file != sys.stdout:
			if not self.closeAttempt:
				try:
					self.file.close()
				except Exception as _:
					pass

			try:
				os.remove(self.fileName)
			except Exception as _:
				pass


	def writeLine(self, string):
		self.file.write(bytes(string + '\n', 'ascii'))


	def writeZStr(self, string, numZeros):
		self.file.write(bytes(string, 'ascii'))

		if numZeros > 0:
			self.file.write(bytes(numZeros))
