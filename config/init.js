'use strict';

/**
 * Module dependencies.
 */
var glob = require('glob'),
	chalk = require('chalk');

/**
 * Module init function.
 */
module.exports = function() {
    if (!process.env.QUILT_ENV) {
        console.error(chalk.red('QUILT_ENV is not defined! Using default development environment'));
	    process.env.QUILT_ENV =  'development';
 	} else {
	    console.log(chalk.black.bgWhite('Loading using the "' + process.env.QUILT_ENV + '" environment configuration'));
	}
};
