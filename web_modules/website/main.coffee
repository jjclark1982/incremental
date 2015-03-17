console.log('Loaded app with config:', process.env)

require('file?name=index.html!./index.html')
require('file?name=CNAME!./CNAME')
require('./style.css')

init = ->
    React = require('react')
    App = require('./app')

    contentEl = document.getElementById('content')
    if !contentEl
        contentEl = document.createElement('div')
        document.body.appendChild(contentEl)

    React.render(React.createElement(App), contentEl)

init()
