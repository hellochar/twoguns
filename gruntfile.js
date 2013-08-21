'use strict';

module.exports = function(grunt) {

    grunt.initConfig({
        clean: ['compiled/js/'],
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
        watch: {
            scripts: {
                files: ['**/*.coffee'],
                tasks: ['coffee'],
            },
        },
    });

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('default', ['clean', 'coffee', 'watch']);
}
