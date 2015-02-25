gulp = require('gulp')
$ = require('gulp-load-plugins')()

gulp.task('default', ['server'])

gulp.task('server', (ready)->
    browserSync = require('browser-sync')

    browserSync({
        port: process.env.PORT or 3000
        server: {
            baseDir: __dirname+'/public'
        }
        files: __dirname+'/public/**'
        online: false
        open: false
        notify: false
    }, ->
        # ready()
    )
)
