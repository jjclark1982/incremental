# console.log('Loaded app with config:', process.env)

try
    require('file?name=index.html!./index.html')
    require('file?name=CNAME!./CNAME')
    require('./style.css')
    require('es5-shim/es5-shim')
    require('es5-shim/es5-sham')
    require('console-polyfill')

React = require('react')
App = require('./app')

contentEl = document.getElementById('content')
if !contentEl
    contentEl = document.createElement('div')
    document.body.appendChild(contentEl)

React.render(React.createElement(App), contentEl)
