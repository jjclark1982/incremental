React = require('react')
AccumulatorInspector = require('./accumulator-inspector')
FPS = require('./fps')

IncrementalApp = React.createClass({
    displayName: 'IncrementalApp'

    getInitialState: ->
        {fps: 12}

    componentWillMount: ->
        FPS.setTarget(12)
        FPS.callbacks.push(=>
            @setState({fps: Math.round(FPS.measuredFPS)})
        )

    shouldComponentUpdate: (nextProps, nextState)->
        if nextState.fps isnt @state.fps
            return true
        return false

    render: ->
        # this is not usually visible

        return <div>
            <h1>Incremental</h1>
            <div style={position: 'absolute', top: '0.5em', right: '0.5em'}>{@state.fps} FPS</div>
            <AccumulatorInspector saveKey="accumulator" />
        </div>
})

module.exports = IncrementalApp
