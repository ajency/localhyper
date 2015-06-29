module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compileJoined:
        options:
          join: true
        files:
          'cloud/main.js':
            [
             'source/*.coffee'
             'source/entities/*.coffee'
            ]
    watch:
      files: 
        [
          'source/*.coffee'
          'source/entities/*.coffee'
        ]
      tasks:
        [
          'coffee'
#         'other-task'
        ]

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['coffee']