React = require('react')
AccumulatorView = require('accumulator/view')
FPSControl = require('fps-control')

IncrementalApp = React.createClass({
    displayName: 'IncrementalApp'

    render: ->
        return <div>
            <span id="forkongithub"><a href="https://github.com/jjclark1982/incremental">Fork me on GitHub</a></span>
            <h1>Incremental</h1>
            <AccumulatorView saveKey="accumulator" />
            <FPSControl />
        </div>
})

module.exports = IncrementalApp
