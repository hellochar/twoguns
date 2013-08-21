'use strict';

module.exports = function(grunt) {

    grunt.initConfig({
        clean: ['compiled/js/'],
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
    });

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.event.on('watch', function(action, filepath) {

        var js_filepath = filepath.replace(/coffee\/(.*)\.coffee/, "compiled/js/$1.js");

        if(action == 'deleted') {
            console.log("deleting", js_filepath);
            grunt.file.delete(js_filepath);
        } else {
            grunt.config(['coffee', 'singleFile', 'src'], filepath);
            grunt.config(['coffee', 'singleFile', 'dest'], js_filepath);
        }
    });

    grunt.registerTask('default', ['clean', 'coffee:all', 'watch']);
}
