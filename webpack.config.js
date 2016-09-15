var webpack = require('webpack');
var path = require('path');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var autoprefixer = require('autoprefixer');
var failPlugin = require('webpack-fail-plugin');
var CopyPlugin = require('copy-webpack-plugin');

// client environment configuration.
// (these default values will be overridden by by the current environment)

// default values will be overridden by current environment
var packageInfo = require('./package');
var env = {
    NODE_ENV: 'development',
    PACKAGE_NAME: packageInfo.name,
    PACKAGE_VERSION: packageInfo.version
};
for (var key in env) {
    if (key in process.env) {
        env[key] = process.env[key];
    }
    env[key] = JSON.stringify(env[key]);
}

// keep a pointer to css loader so it can change based on environment
var cssPlugin = new ExtractTextPlugin('[name]-style.css');
var cssLoader = {
    test: /\.css$/,
    loader: cssPlugin.extract("style", "css!postcss")
}

// main config object
var config = {
    devtool: process.env.WEBPACK_DEVTOOL || 'source-map',
    profile: true,
    entry: {
        main: 'main'
    },
    output: {
        path: path.join(__dirname, 'public'),
        filename: '[name]-script.js'
    },
    plugins: [
        new webpack.DefinePlugin({'process.env': env}),
        cssPlugin, 
        failPlugin,
        new CopyPlugin([{
            from: 'static'
        }])
    ],
    postcss: function(webpack) {
        return [
            autoprefixer({browsers: '> 0.1%'})
        ]
    },
    resolve: {
        extensions: ['', '.js', '.jsx', '.cjsx', '.coffee']
    },
    module: {
        loaders: [
            cssLoader,
            {
                test: /\.jsx?$/,
                exclude: /(node_modules|bower_components)/,
                loader: 'babel',
            },
            {
                test: /\.cjsx$/,
                loaders: ['coffee', 'cjsx']
            },
            {
                test: /\.coffee$/,
                loader: 'coffee'
            },
            {
                test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
                loader: "file"
            },
            {
                test: /\.(woff|woff2)$/,
                loader: "url",
                query: {limit: 5000, prefix:"font/"}
            },
            {
                test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
                loader: "url",
                query: {limit: 10000, mimetype:"application/octet-stream", name:"[path][name].[ext]?[hash]"}
            },
            {
                test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
                loader: "url",
                query: {limit: 10000, mimetype:"image/svg+xml", name:"[path][name].[ext]?[hash]"}
            },
            {
                test: /\.gif/,
                loader: "url",
                query: {limit: 10000, mimetype:"image/gif", name:"[path][name].[ext]?[hash]"}
            },
            {
                test: /\.jpe?g/,
                loader: "url",
                query: {limit: 10000, mimetype:"image/jpg", name:"[path][name].[ext]?[hash]"}
            },
            {
                test: /\.png/,
                loader: "url",
                query: {limit: 10000, mimetype:"image/png", name:"[path][name].[ext]?[hash]"}
            }
        ]
    }
};

config.devServer = {
    host: process.env.HOST || '127.0.0.1',
    port: process.env.PORT || '8080',
    contentBase: config.output.path,
    publicPath: '/',
    compress: true
}

// automatically add all 'test.*' files to the 'test' entrypoint
try {
    require.resolve('mocha');
    config.entry.test = [];
    var testFiles = require('./test');
    for (var i = 0; i < testFiles.length; i++) {
        config.entry.test.push('mocha!'+testFiles[i]);
    }
} catch (e) {
    // don't add tests if mocha is missing
}

// in production mode, minimize file-size
if (process.env.NODE_ENV === 'production') {
    config.plugins.push(new webpack.optimize.UglifyJsPlugin());
}

// when running webpack-dev-server, enable hot module reloading
if (require.cache[require.resolve('webpack-dev-server')]) {
    config.plugins.push(new webpack.NoErrorsPlugin());
    config.plugins.push(new webpack.HotModuleReplacementPlugin());
    config.devServer.hot = true;
    config.devServer.inline = true;
    cssLoader.loader = "style!css!postcss";
}

module.exports = config;
