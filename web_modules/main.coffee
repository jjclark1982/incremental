console.log('Loaded app with config:', process.env)

require('file?name=index.html!./assets/index.html')
require('file?name=CNAME!./assets/CNAME')
require('purecss/pure.css') # this flickers, we may want to put it in a separate file.

init = ->
    React = require('react')
    App = require('app')

    contentEl = document.getElementById('content')
    if !contentEl
        contentEl = document.createElement('div')
        document.body.appendChild(contentEl)

    React.render(React.createElement(App), contentEl)

init()
