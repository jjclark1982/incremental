React = require('react')
FPS = require('./fps')

style = {
    display: 'inline-block',
    textAlign: 'center',
    margin: '0.5em',
    border: '1px solid #ccc',
    padding: '0.5em'
}

FPSControl = React.createClass({
    displayName: 'FPSControl'

    getInitialState: ->
        return {
            targetFPS: FPS.targetFPS
            measuredFPS: FPS.targetFPS
        }

    componentWillMount: ->
        FPS.callbacks.push(=>
            @setState({measuredFPS: Math.round(FPS.measuredFPS)})
        )

    shouldComponentUpdate: (nextProps, nextState)->
        if nextState.measuredFPS isnt @state.measuredFPS
            return true
        if nextState.targetFPS isnt @state.targetFPS
            return true
        return false

    changed: (event)->
        targetFPS = event.target.value
        FPS.setTarget(event.target.value)
        @setState({
            targetFPS: targetFPS
        })

    render: ->
        return <div style={style}>
            {@state.measuredFPS}/{@state.targetFPS} FPS
            <br/>
            <input type="range" min=1 max=60 onChange={@changed} defaultValue={12} />
        </div>
})

module.exports = FPSControl