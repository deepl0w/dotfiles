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

function parseDec(name, s, minValue, maxValue) {
	let value = parseInt(s, 10);

	if (s.match(/^-?\d+$/) === null) {
		throw new Error(util.format('invalid %s format', name));
	}
	if (value < minValue) {
		throw new Error(util.format('%s must be >= %d', name, minValue));
	}
	if (value > maxValue) {
		throw new Error(util.format('%s must be <= %d', name, maxValue));
	}

	return value;
}

function parseHex(name, s, minValue, maxValue) {
	let value = parseInt(s, 16);

	if (s.match(/^[\dA-Fa-f]+$/) === null) {
		throw new Error(util.format('invalid %s format', name));
	}
	if (minValue == null) {
		minValue = 0;
	}
	if (maxValue == null) {
		maxValue = 0x10FFFF;
	}
	if (value < minValue) {
		throw new Error(util.format('%s must be >= %s', minValue.toString(16).toUpperCase()));
	}
	if (value > maxValue) {
		throw new Error(util.format('%s must be <= %s', maxValue.toString(16).toUpperCase()));
	}

	return value;
}

function unQuote(s, name) {
	if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
		s = s.substring(1, s.length - 1);
	} else if (name != null) {
		throw new Error(name + ' must be quoted');
	}

	return s;
}

function startCli(programName, parseArgv, argopts, mainProgram) {
	let excstk = false;

	try {
		let optind;

		if (Number(process.version.match(/^v?(\d+\.\d+)/)[1]) < 6.8) {
			throw new Error('node v6.8.0 or later required');
		}

		// should replace the global option values with a dict
		for (optind = 2; optind < process.argv.length; optind++) {
			let opt = process.argv[optind];

			if (opt === '-' || !opt.startsWith('-')) {
				break;
			}

			if (opt === '--') {
				optind++;
				break;
			}

			if (opt === '--excstk') {
				excstk = true;
			} else {
				let optarg = null;

				if (argopts.indexOf(opt[1]) !== -1) {
					if (opt.length === 2) {
						if (++optind === process.argv.length) {
							throw new Error('option ' + opt + ' requires an argument');
						}
						optarg = process.argv[optind];
					} else {
						optarg = opt.substring(2);
						opt = opt.substring(0, 2);
					}
				}

				parseArgv(opt, optarg);
			}
		}

		mainProgram(optind);
	} catch (e) {
		if (excstk) {
			throw e;
		} else {
			process.stderr.write(util.format('%s: %s\n', programName, e.message));
			process.exit(1);
		}
	}
}

function showLicense(prefix) {
	process.stdout.write(prefix +
		'\n' +
		'This program is free software; you can redistribute it and/or\n' +
		'modify it under the terms of the GNU General Public License as\n' +
		'published by the Free Software Foundation; either version 2 of\n' +
		'the License, or (at your option) any later version.\n' +
		'\n' +
		'This program is distributed in the hope that it will be useful,\n' +
		'but WITHOUT ANY WARRANTY; without even the implied warranty of\n' +
		'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n' +
		'GNU General Public License for more details.\n'
	);
}

// EXPORTS
module.exports = Object.freeze({
	parseDec,
	parseHex,
	unQuote,
	startCli,
	showLicense
});
