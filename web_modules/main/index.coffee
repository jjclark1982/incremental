# console.log('Loaded app with config:', process.env)

try
    require('./style.css')
    require('es5-shim/es5-shim')
    require('es5-shim/es5-sham')

React = require('react')
ReactDOM = require('react-dom')
App = require('./app')

contentEl = document.getElementById('content')
if !contentEl
    contentEl = document.createElement('div')
    document.body.appendChild(contentEl)

ReactDOM.render(React.createElement(App), contentEl)
