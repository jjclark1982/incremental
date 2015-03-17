React = require('react')
AccumulatorView = require('accumulator/view')
FPSControl = require('fps-control')

IncrementalApp = React.createClass({
    displayName: 'IncrementalApp'

    render: ->
        # this is not usually visible

        return <div>
            <h1>Incremental</h1>
            <AccumulatorView saveKey="accumulator" />
            <FPSControl />
        </div>
})

module.exports = IncrementalApp
