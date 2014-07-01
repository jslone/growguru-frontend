'use strict';

pkg = require './package.json'

# Using exclusion patterns slows down Grunt significantly
# instead of creating a set of patterns like '**/*.js' and '!**/node_modules/**'
# this method is used to create a set of inclusive patterns for all subdirectories
# skipping node_modules, bower_components, dist, and any .dirs
# This enables users to create any directory structure they desire.
createFolderGlobs = (fileTypePatterns) ->
  fileTypePatterns = if Array.isArray fileTypePatterns then fileTypePatterns else [fileTypePatterns]
  ignore = ['node_modules', 'bower_components', 'dist', 'temp']
  fs = require 'fs'
  items = fs.readdirSync(process.cwd()).map (file) ->
    if ignore.indexOf(file) isnt -1 or file.indexOf('.') is 0 or not fs.lstatSync(file).isDirectory()
      null
    else
      fileTypePatterns.map (pattern) -> file + '/**/' + pattern
  .filter (patterns) ->
     patterns isnt null
  .concat fileTypePatterns
  [].concat.apply [], items


module.exports = (grunt) ->

  #  load all grunt tasks
  require('load-grunt-tasks') grunt

  #  Time how long tasks take. Can help when optimIzing build times
  require('time-grunt') grunt

  #  Project configuration.
  grunt.initConfig

    connect:
      main:
        options:
          port: 9001
          #  Change this to '0.0.0.0' to access the server from outside.
          hostname: 'localhost'
          livereload: 35729
          base: [
            'temp'
            '.'
          ]
      reloadonly:
        options:
          #port: 9001
          hostname: 'localhost'
          livereload: 35729
          base: ['.']

    watch:
      main:
        options:
          livereload: true
          livereloadOnError: false
          spawn: false
        files: createFolderGlobs [
            '*.coffee'
            '*.less'
            '*.html'
            '*.s?ss'
            '!_SpecRunner.html'
            '!.grunt'
            '!Gruntfile.coffee'
          ]
        tasks: [] # all the tasks are run dynamically during the watch event handler
      # bower:
      #   files: ['bower.json']
      #   tasks: ['bowerInstall']

      gruntfile:
        files: ['Gruntfile.coffee']

    shell:
      nodewebkit:
        command: 'nodewebkit .'
        options:
          async: true
          stdin: false
          stdout: false
          stderr: true
          failOnError: true
          execOptions: { cwd: '.' }

    coffee:
      main:
        options:
          sourceMap: true
          sourceRoot: ''
        src: createFolderGlobs ['*.coffee', '!Gruntfile.coffee']
        expand: true
        #cwd: '.'
        #dest: '.'
        ext: '.js'

    jshint:
      main:
        options:
          jshintrc: '.jshintrc'
        src: createFolderGlobs '*.js'

    clean:
      before:
        src: ['dist', 'temp']
      after:
        src: [
          'temp'
          createFolderGlobs ['*~', '*.js', '*.js.map']
        ]
    sass:
      production:
        options:
          sourcemap: true
        files:
          'temp/app.css': 'app.s?ss'
    less:
      production:
        options: {}
        files:
          'temp/app.css': 'app.less'

    ngtemplates:
      main:
        options:
          packagename: pkg.name
          module: '<%= _.camelize(ngtemplates.main.options.packagename) %>'
          htmlmin: '<%= htmlmin.main.options %>'
        src: [createFolderGlobs('*.html'), '!index.html', '!_SpecRunner.html'],
        dest: 'temp/templates.js'

    copy:
      main:
        files: [
          {src: ['img/**'], dest: 'dist/'}
          {src: ['bower_components/font-awesome/fonts/**'], dest: 'dist/',filter:'isFile',expand:true}
          # {src: ['bower_components/angular-ui-utils/ui-utils-ieshiv.min.js'], dest: 'dist/'}
          # {src: ['bower_components/select2/*.png','bower_components/select2/*.gif'], dest:'dist/css/',flatten:true,expand:true}
          # {src: ['bower_components/angular-mocks/angular-mocks.js'], dest: 'dist/'}
        ]

    dom_munger:
      read:
        options:
          read: [
            {selector: 'script[data-concat!="false"][data-appjs!="true"]', attribute: 'src', isPath:true, writeto: 'libjs'}
            {selector: 'script[data-concat!="false"][data-appjs="true"]', attribute: 'src', isPath:true, writeto: 'appjs'}
            {selector: 'link[rel="stylesheet"][data-concat!="false"]', attribute: 'href', isPath:true, writeto: 'appcss'}
          ]
        src: 'index.html'
      update:
        options:
          remove: ['script[data-remove!="false"]', 'link[data-remove!="false"]']
          append: [
            {selector: 'body',html: '<script src="app.full.min.js"></script>'}
            {selector: 'head',html: '<link rel="stylesheet" href="app.full.min.css">'}
          ]
        src: 'index.html'
        dest: 'dist/index.html'

    cssmin:
      main:
        src: ['temp/app.css', '<%= dom_munger.data.appcss %>']
        dest: 'dist/app.full.min.css'

    concat:
      main:
        src: [
          '<%= dom_munger.data.libjs %>'
          '<%= dom_munger.data.appjs %>'
          '<%= ngtemplates.main.dest %>'
        ]
        dest: 'temp/app.full.js'

    ngmin:
      main:
        src: 'temp/app.full.js'
        dest: 'temp/app.full.js'

    uglify:
      main:
        src: 'temp/app.full.js'
        dest: 'dist/app.full.min.js'

    htmlmin:
      main:
        options:
          collapseBooleanAttributes: true
          collapseWhitespace: true
          removeAttributeQuotes: true
          removeComments: true
          removeEmptyAttributes: true
          removeScriptTypeAttributes: true
          removeStyleLinkTypeAttributes: true
        files:
          'dist/index.html': 'dist/index.html'

    imagemin:
      main:
        files: [
          expand: true
          cwd: 'dist/'
          src: ['**/{*.png,*.jpg}']
          dest: 'dist/'
        ]

    karma:
      options:
        frameworks: ['jasmine']
        files: [  # this files data is also updated in the watch handler, if updated change there too
          '<%= dom_munger.data.libjs %>'
          '<%= dom_munger.data.appjs %>'
          'bower_components/angular-mocks/angular-mocks.js'
          createFolderGlobs '*-spec.js'
        ]
        logLevel: 'ERROR'
        reporters: ['mocha']
        autoWatch: false # watching is handled by grunt-contrib-watch
        singleRun: true
      all_tests:
        #browsers: ['PhantomJS', 'Chrome', 'Firefox']
        #browsers: ['PhantomJS']
        browsers: ['NodeWebkit']
      during_watch:
        browsers: ['PhantomJS']

  grunt.registerTask 'build', [
    # 'jshint'
    'clean:before'
    'coffee'
    'less'
    'sass'
    'dom_munger'
    'ngtemplates'
    'cssmin'
    'concat'
    'ngmin'
    'uglify'
    'copy'
    'htmlmin'
    'imagemin'
    'clean:after'
  ]

  grunt.registerTask 'serve', [
    'dom_munger:read'
    # 'newer:jshint'
    'newer:coffee:main'
    'connect'
    'watch'
  ]

  grunt.registerTask 'nw', [
    'dom_munger:read'
    # 'newer:jshint'
    'newer:coffee:main'
    'connect:reloadonly'
    'shell:nodewebkit'
    'watch'
  ]

  grunt.registerTask 'test', [
    'dom_munger:read'
    'newer:coffee:main'
    'karma:all_tests'
  ]


  grunt.event.on 'watch', (action, filepath) ->
    # https://github.com/gruntjs/grunt-contrib-watch/issues/156

    if action != 'changed'
      return

    tasksToRun = []
    path = require 'path'
    extension = path.extname filepath

    if extension is '.coffee'
      tasksToRun.push 'newer:coffee'
    if extension is '.sass' or extension is '.scss'
      tasksToRun.push 'sass'

      # determine if there is a corresponding -spec file
      base = path.basename filepath, '.coffee'
      dir = path.dirname filepath

      testBase =
        if base.lastIndexOf('-spec') is base.length - 5
          (path.join dir, base)
        else
          (path.join dir, base) + '-spec'

      testFile = testBase + '.coffee'
      if grunt.file.exists testFile
        files = [].concat grunt.config 'dom_munger.data.libjs'
        appScripts = [].concat grunt.config 'dom_munger.data.appjs'
        files.push appScripts
        files.push 'bower_components/angular-mocks/angular-mocks.js'

        testFileJS = testBase + '.js'
        files.push testFileJS

        grunt.config 'karma.options.files', files
        tasksToRun.push 'karma:during_watch'

    # if index.html changed, we need to reread the <script> tags so our next run of karma
    # will have the correct environment
    if filepath is 'index.html'
      tasksToRun.push 'dom_munger:read'

    # run all accumulated tasks
    grunt.config 'watch.main.tasks', tasksToRun
