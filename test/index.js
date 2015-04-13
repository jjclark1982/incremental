// exports a list of all the 'test.*' files within web_modules

var glob = require('glob');

files = glob.sync('**/test.*', {cwd: 'web_modules', ignore: '**/*.html'});

module.exports = files;
