console.log('Loaded app with config:', process.env)

require('file?name=index.html!./assets/index.html')
require('purecss/pure.css') # this flickers, we may want to put it in a separate file.

init = ->
    # when all libraries have loaded, load components and render the app
    React = require('react')
    # App = require('./components/app')

    contentEl = document.getElementById('content')
    if !contentEl
        contentEl = document.createElement('div')
        document.body.appendChild(contentEl)

    # React.render(React.createElement(App), contentEl)

init()
