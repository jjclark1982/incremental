var path = require('path');
var webpack = require('webpack');
var autoprefixer = require('autoprefixer-core');
var atImport = require('postcss-import');
var cssWring = require('csswring');

// client environment configuration.
// (these default values will be overridden by by the current environment)

var env = {
    NODE_ENV: 'development'
};
for (var key in env) {
    if (typeof process.env[key] !== 'undefined') {
        env[key] = process.env[key];
    }
    env[key] = JSON.stringify(env[key]);
}

// webpack configuration

var config = {
    context: path.join(__dirname, 'src'),
    entry: ['./main.coffee'],
    output: {
        path: path.join(__dirname, 'public'),
        filename: 'bundle.js'
    },
    resolveLoader: {
        modulesDirectories: ['node_modules']
    },
    resolve: {
        extensions: ['', '.js', '.cjsx', '.coffee']
    },
    module: {
        loaders: [
            { test: /\.css$/, loaders: ['style', 'css', 'postcss'] },
            { test: /\.cjsx$/, loaders: ['react-hot', 'coffee', 'cjsx'] },
            { test: /\.coffee$/, loader: 'coffee' }
        ]
    },
    plugins: [
        new webpack.NoErrorsPlugin(),
        new webpack.optimize.DedupePlugin(),
        new webpack.DefinePlugin({'process.env': env})
    ],
    postcss: [
        atImport({path: path.join(__dirname, 'src')}),
        autoprefixer({browsers: '> 0.1%'})
    ]
};

if (process.env.NODE_ENV === 'production') {
    // note that the react library will also be optimized due to the DefinePlugin.
    config.plugins.push(new webpack.optimize.UglifyJsPlugin());
    config.postcss.push(cssWring);
}
else {
    config.devtool = 'source-map';
    config.debug = true;
}

// webpack-dev-server configuration

config.devServer = {
    host: process.env.HOST || 'localhost',
    port: process.env.PORT || 8080,
    contentBase: config.output.path,
    publicPath: '/',
    hot: true,
    stats: { colors: true }
};
if (require.cache[require.resolve('webpack-dev-server')]) {
    // we appear to be running the dev server. enable hot reloading.
    config.entry.push('webpack/hot/dev-server');
    config.entry.push('webpack-dev-server/client?http://'+config.devServer.host+':'+config.devServer.port);
    config.plugins.push(new webpack.HotModuleReplacementPlugin());
}

module.exports = config;