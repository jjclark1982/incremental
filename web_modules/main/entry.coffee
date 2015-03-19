console.log('Loaded app with config:', process.env)

# window.filename = require('file?name=[name].[ext]!./index.html')
require('./index.jade')
require('file?name=[name]!./CNAME')
require('./style.css')

React = require('react')
App = require('./app')

contentEl = document.getElementById('content')
if !contentEl
    contentEl = document.createElement('div')
    document.body.appendChild(contentEl)

React.render(React.createElement(App), contentEl)
