'use strict';

module.exports = function(grunt) {

    var path = require('path');

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        clean: {
            options: {force: true},
            compiled: ['compiled/js/'],
        },
        coffee: {
            all: {
                files: [{
                    expand: true,
                    cwd: 'coffee/',
                    src: '**/*.coffee',
                    dest: 'compiled/js/',
                    ext: '.js',
                }],
            },
            singleFile: {
                src: '',
                dest: '',
            },
        },

        env: {
            dev : {
                NODE_ENV: 'development',
            },
        },

        watch: {
            coffee_changed: {
                files: 'coffee/**/*.coffee',
                tasks: 'coffee:singleFile',
                options: {
                    livereload: true,
                    spawn: false,
                    event: ['added', 'changed'],
                },
            },
            coffee_deleted: {
                files: 'coffee/**/*.coffee',
                tasks: '',
                options: {
                    livereload: true,
                    spawn: false,
                    event: ['deleted'],
                },
            },
        },
        nodemon: {
            dev: {
                options: {
                    watchedFolders: ['<%= pkg.main %>'],
                },
            },
        },
        concurrent: {
            dev: {
                tasks: ['nodemon:dev', 'watch'],
                options: {
                    logConcurrentOutput: true,
                },
            },
        },

    });

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-env');
    grunt.loadNpmTasks('grunt-nodemon');

    grunt.event.on('watch', function(action, filepathString) {

        //should be of the form [coffee, dir1, dir2, ... file.coffee]
        var pathComponents = filepathString.split(path.sep)

        var jsPathComponents = ["compiled", "js"]
        jsPathComponents.push.apply(jsPathComponents, pathComponents.slice(1, -1))
        var new_filename = path.basename(filepathString, ".coffee") + ".js";
        jsPathComponents.push(new_filename);
        var js_filepath = jsPathComponents.join(path.sep)

        if(action == 'deleted') {
            console.log("deleting", js_filepath);
            grunt.file.delete(js_filepath);
        } else {
            grunt.config(['coffee', 'singleFile', 'src'], filepathString);
            grunt.config(['coffee', 'singleFile', 'dest'], js_filepath);
        }
    });

    grunt.registerTask('default', ['env:dev', 'clean:compiled', 'coffee:all', 'concurrent:dev']);
}
