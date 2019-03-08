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

def parseDec(name, s, minValue, maxValue):
	value = int(s)

	if value < minValue:
		raise Exception('{0} must be >= {1}'.format(name, minValue))

	if value > maxValue:
		raise Exception('{0} must be <= {1}'.format(name, maxValue))

	return value


def parseHex(name, s, minValue=0, maxValue=0x10FFFF):
	value = int(s, 16)

	if value < minValue:
		raise Exception('{0} must be >= {1}'.format(name, hex(minValue)[2:].upper()))

	if value > maxValue:
		raise Exception('{0} must be <= {1}'.format(name, hex(maxValue)[2:].upper()))

	return value


def unQuote(s, name=None):
	if len(s) >= 2 and s.startswith('"') and s.endswith('"'):
		s = s[1:len(s) - 1]
	elif name != None:
		raise Exception(name + ' must be quoted')

	return s


def startCli(programName, parseArgv, argopts, mainProgram):
	excstk = False

	try:
		if sys.hexversion < 0x3040000:
			raise Exception('python 3.4.0 or later required')

		# should replace the global option values with a dict
		optind = 1
		while optind < len(sys.argv):
			opt = sys.argv[optind]

			if opt == '-' or not opt.startswith('-'):
				break

			if opt == '--':
				optind += 1
				break

			if opt == '--excstk':
				excstk = True
			else:
				optarg = None

				if argopts.find(opt[1]) != -1:
					if len(opt) == 2:
						optind += 1
						if optind == len(sys.argv):
							raise Exception('option ' + opt + ' requires an argument')

						optarg = sys.argv[optind]
					else:
						optarg = opt[2:]
						opt = opt[0:2]

				parseArgv(opt, optarg)

			optind += 1

		mainProgram(optind)
	except Exception as e:
		if excstk:
			raise
		else:
			sys.stderr.write('{0}: {1}\n'.format(programName, e))
			sys.exit(1)


def showLicense(prefix):
	sys.stdout.write(prefix +
		'\n' +
		'This program is free software; you can redistribute it and/or\n' +
		'modify it under the terms of the GNU General Public License as\n' +
		'published by the Free Software Foundation; either version 2 of\n' +
		'the License, or (at your option) any later version.\n' +
		'\n' +
		'This program is distributed in the hope that it will be useful,\n' +
		'but WITHOUT ANY WARRANTY; without even the implied warranty of\n' +
		'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n' +
		'GNU General Public License for more details.\n')
