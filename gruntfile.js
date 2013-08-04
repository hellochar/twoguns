'use strict';

module.exports = function(grunt) {

    grunt.initConfig({
        coffee: {
            dynamic_mappings: {
                files: [{
                    expand: true,
                    cwd: 'coffee/',
                    src: ['**/*.coffee'],
                    dest: 'out/',
                    ext: '.js',
                }],
            },
        },
    });

    grunt.loadNpmTasks('grunt-contrib-coffee');
}
