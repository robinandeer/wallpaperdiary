# --------------------------------------------------
#  Grunt.js Task File
# --------------------------------------------------

# Makes a folder avaliable as a static resource to the broswer
#   @connect - The connect instance
#   @dir     - The static directory to make available
mountFolder = (connect, dir) ->
  return connect.static require("path").resolve(dir)

# Configure Grunt
module.exports = (grunt) ->
  # Load all the grunt tasks that are installed as dev dependencies
  # Replaces manually loading every NPM task!
  require("load-grunt-tasks")(grunt)

  grunt.initConfig
    # Livereload JS, HTML and Ember.js templates, inject CSS.
    # http://draftingcode.com/2013/06/subtle-live-reloading-with-grunt-and-compass/
    watch:
      # Watch sass files in the styles sub-directory and one level down.
      # N.B. Don't reload the browser! We want to simply inject new CSS.
      sass:
        files: ["sass/**/*.{sass,scss}"]
        tasks: ["sass"]

      # Watch static files (HTML, ?) that should be copied to the "tmp" folder.
      copy:
        files: ["public/**"]
        tasks: ["copy"]
        options: { livereload: true }

      # This is how we can inject CSS into the page without reloading!
      livereload:
        files: [".tmp/css/*.css"]
        options: { livereload: true }

    # Connect is used to set up a development server
    connect:
      server:
        options:
          port: 9000
          # Change this to "0.0.0.0" to access the server from outside
          hostname: "localhost"

          # This is required to get the livereload working
          middleware: (connect) ->
            return [
              require("connect-livereload")()
              # Make these folders available to the browser
              mountFolder connect, ".tmp"
              mountFolder connect, "."
            ]

    # Sass (only .scss) tasks
    sass:
      options:
        debugInfo: yes
        sourcemap: yes

      dist:
        files:
          ".tmp/css/app.css": "sass/app.scss"

    # Clean up the compilation folders
    clean:
      build: [".tmp"]
      release: ["dist"]

    # Copies static files to the "tmp" folder to be served to browser
    copy:
      main:
        expand: yes
        cwd: "public/"
        src: "**"
        dest: ".tmp/"

    open:
      server:
        path: "http://localhost:<%= connect.server.options.port %>"

  # I only have a single task list but will build this out to include tests
  # and dist in the future.
  grunt.registerTask "default", [
    "clean:build",
    "copy",
    "sass",
    "connect",
    "open",
    "watch"
  ]