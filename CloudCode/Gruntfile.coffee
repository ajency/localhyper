module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compileJoined:
        options:
          join: true
        files:
          'js/main.js':
            [
             'source/*.coffee'
             'source/entities/*.coffee'
            ]
    uglify:
      my_target: files: 'cloud/main.js': [ 'js/main.js' ]            
    watch:
      files: 
        [
          'source/*.coffee'
          'source/entities/*.coffee'
        ]
      tasks:
        [
          'coffee'
          'uglify'
        ]

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.registerTask 'default', ['coffee']