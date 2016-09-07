'use strict';

var _ = require('lodash');

module.exports = function(grunt) {

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        watch: {
            scripts: {
                files: ['application/**/*.sql'],
                tasks: ['loadConfig', 'reinstall', 'test'],
                options: {
                    reload: true,
                    spawn: false
                },
            },
            tests: {
                files: ['test/**/*.sql'],
                tasks: ['loadConfig', 'test'],
                options: {
                    reload: true,
                    spawn: false
                }
            }
        },

        shell: {
            runSuperUserScript : {
                command: function (script) {
                    return '<%= sqlTool %> <%= superUserDbConnectString %> @' + script + '.sql <%= environment %>'
                }
            },
            runAppUserScript : {
                command: function (script) {
                    return '<%= sqlTool %> <%= appUserDbConnectString %> @' + script + '.sql'
                }
            },
            sqlScript : {
                command: function(connectString, script, testTarget) {
                    return '<%= sqlTool %> <%= '+ connectString +' %> @' + script + '.sql ' + testTarget
                }
            }
        }

    });

    require('load-grunt-tasks')(grunt);

	grunt.option('force', true);

    grunt.task.registerTask('loadConfig', 'Task that loads config into a grunt option', function() {
	    var init = require('./config/init')();
	    var config = require('./config/config');

        grunt.config.set('environment', process.env.QUILT_ENV);
        grunt.config.set('sqlTool', config.sqlTool);
        grunt.config.set('superUserDbConnectString', config.db.superUserDbConnectString);
        grunt.config.set('appUserDbConnectString', config.db.appUserDbConnectString);
        grunt.config.set('tstProfiledAppUserDbConnectString', config.db.tstProfiledAppUserDbConnectString);
        grunt.config.set('tstPrivProfilerUserDbConnectString', config.db.tstPrivProfilerUserDbConnectString);
        grunt.config.set('tstUnprivProfilerUserDbConnectString', config.db.tstUnprivProfilerUserDbConnectString);
    });

    grunt.registerTask('ci', ['loadConfig', 'reinstall', 'test', 'watch']);

    grunt.registerTask('ct', ['loadConfig', 'watch']);

    // Tests

    // singleschema
    // TODO: define test targets as array in config and unwind script with array, or for each directory in test
    grunt.registerTask('install_test',   ['loadConfig',
                                            'shell:sqlScript:appUserDbConnectString:install_test:singleschema',
                                            'shell:sqlScript:tstProfiledAppUserDbConnectString:install_test:multischema_profiled_app',
                                            'shell:sqlScript:tstPrivProfilerUserDbConnectString:install_test:multischema_privileged_profiler',
                                            'shell:sqlScript:tstUnprivProfilerUserDbConnectString:install_test:multischema_unprivileged_profiler'
                                         ]);
    grunt.registerTask('uninstall_test', ['loadConfig',
                                            'shell:sqlScript:appUserDbConnectString:uninstall_test:singleschema',
                                            'shell:sqlScript:tstProfiledAppUserDbConnectString:uninstall_test:multischema_profiled_app',
                                            'shell:sqlScript:tstPrivProfilerUserDbConnectString:uninstall_test:multischema_privileged_profiler',
                                            'shell:sqlScript:tstUnprivProfilerUserDbConnectString:uninstall_test:multischema_unprivileged_profiler'
                                         ]);
    grunt.registerTask('reinstall_test', ['loadConfig', 'uninstall_test', 'install_test']);
    grunt.registerTask('test',           ['loadConfig',
                                            'shell:sqlScript:appUserDbConnectString:test:singleschema',
                                            'shell:sqlScript:tstPrivProfilerUserDbConnectString:test:multischema_privileged_profiler',
                                            'shell:sqlScript:tstUnprivProfilerUserDbConnectString:test:multischema_unprivileged_profiler'
                                         ]);
    // Users & Application

    grunt.registerTask('create', ['loadConfig', 'shell:runSuperUserScript:create']);

    grunt.registerTask('drop', ['loadConfig', 'shell:runSuperUserScript:drop']);

    grunt.registerTask('install', ['loadConfig', 'shell:runAppUserScript:install']);

    grunt.registerTask('uninstall', ['loadConfig', 'shell:runAppUserScript:uninstall']);

    grunt.registerTask('reinstall', ['loadConfig', 'shell:runAppUserScript:uninstall', 'shell:runAppUserScript:install']);

}
