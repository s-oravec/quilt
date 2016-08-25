'use strict';

module.exports = {
    db: {
        superUserDbConnectString: process.env.QUILT_SUPERUSER_CONN || 'QUILT_SUPERUSER_CONN',
        appUserDbConnectString:  process.env.QUILT_APPUSER_CONN || 'QUILT_APPUSER_CONN'
    },
};