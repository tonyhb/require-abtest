var gulp = require('gulp');

// Plugins
var coffee = require('gulp-coffee'),
    clean = require('gulp-clean'),
    rename = require('gulp-rename'),
    karma = require('gulp-karma');

// Paths
var paths = {
  coffee: 'coffee/',
  js: 'js/',
  spec: 'spec/'
};

/**
 * Compile Coffee down to JS
 */
function compileCoffee() {
  var stream = gulp.src(paths.coffee + '**/*.coffee')
    .pipe(coffee({bare: true})
    .on('error', console.log))
    .pipe(gulp.dest(paths.js));
  return stream;
}

/**
 * Test through Karma
 */
var test = {
  // Compiles coffeescript specs into JS
  compile: function() {
    var stream = gulp.src(paths.spec + '*.coffee')
      .pipe(coffee({bare: true})
      .on('error', console.log))
      .pipe(rename(function(path) {
        path.basename = 'converted-' + path.basename;
      }))
      .pipe(gulp.dest(paths.spec));
    return stream;
  },

  // Remove compiled specs
  clean: function() {
    return gulp.src(paths.spec + '**/converted-*Spec.js', {read: false})
      .pipe(clean());
  },

  // Run the tests.
  // This is also called from 'watch' after a spec or coffeescript file changes
  run: function() {
    test.compile().on('end', function() {
      test.go('run').on('end', function() {
        test.clean();
      });
    });
  },

  // Test run/watch helper: either runs or launches a single test
  go: function(action) {
    var files = ["undefined.js"];
    return gulp.src(files)
      .pipe(karma({
        configFile: 'karma.conf.js',
        action: action
      }))
      .on('error', console.log);
  }
};

function watch() {
  gulp.watch(paths.sass + '**', ['css']);
  gulp.watch(paths.coffee + '**', ['coffee', 'test-run']);
  gulp.watch(paths.spec + '**/*Spec.coffee', ['test-run']);
}


// Coffee -> JS
gulp.task('coffee', compileCoffee);

// Tests
gulp.task('test', test.run);
gulp.task('test-run', test.run);
gulp.task('test-watch', test.watch);
gulp.task('test-compile', test.compile);
gulp.task('test-clean', test.clean);

// Watch
gulp.task('watch', watch);

// Default: this runs when you type gulp
gulp.task('default', ['coffee', 'watch']);
