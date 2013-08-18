'use strict';

module.exports = function(grunt) {

    grunt.initConfig({
        coffee: {
            dynamic_mappings: {
                files: [{
                    expand: true,
                    cwd: 'coffee/',
                    src: ['**/*.coffee'],
                    dest: 'compiled/js/',
                    ext: '.js',
                }],
            },
        },
    });

    grunt.loadNpmTasks('grunt-contrib-coffee');
}
