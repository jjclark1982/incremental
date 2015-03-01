gulp = require('gulp')
$ = require('gulp-load-plugins')()
del = require('del')

gulp.task('default', ['server'])

gulp.task('clean', (done)->
    del(__dirname+'/public', done)
)

gulp.task('server', (ready)->
    browserSync = require('browser-sync')

    browserSync({
        port: process.env.PORT or 3000
        server: {
            baseDir: __dirname+'/public'
        }
        files: __dirname+'/public/**/*'
        online: false
        open: false
        notify: false
    }, ->
        # ready()
    )
)
