'use strict';

module.exports = {
    db: {
        superUserDbConnectString:            'sys/oracle@local as sysdba',
        appUserDbConnectString:              'QUILT_000100_DEV/QUILT_000100_DEV@local',
        tstProfiledAppUserDbConnectString:   'QUILT_000100_TST_PROF_APP/QUILT_000100_TST_PROF_APP@local',
        tstPrivProfilerUserDbConnectString:  'QUILT_000100_TST_PRIV_PROF/QUILT_000100_TST_PRIV_PROF@local',
        tstUnprivProfilerUserDbConnectString:'QUILT_000100_TST_UNPRIV_PROF/QUILT_000100_TST_UNPRIV_PROF@local',
    },
};