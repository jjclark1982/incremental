React = require('react')
AccumulatorInspector = require('./accumulator-inspector')
FPSControl = require('./fps-control')

IncrementalApp = React.createClass({
    displayName: 'IncrementalApp'

    render: ->
        # this is not usually visible

        return <div>
            <h1>Incremental</h1>
            <AccumulatorInspector saveKey="accumulator" />
            <FPSControl />
        </div>
})

module.exports = IncrementalApp
