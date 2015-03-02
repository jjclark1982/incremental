React = require('react')
Accumulator = require('./accumulator')
Polynomial = require('./polynomial')
clockSkew = require('./clockSkew')
FPS = require('./fps')

AccumulatorInspector = React.createClass({
    displayName: 'AccumulatorInspector'

    getInitialState: ->
        return {
            accumulator: {k: []}
            polynomial: []
            value: 0
        }

    componentWillMount: ->
        saveData = JSON.parse(localStorage.getItem(@props.saveKey))
        @accumulator = new Accumulator(saveData)
        @accumulator.onChange = =>
            @setStateFromAccumulator()
        FPS.callbacks.push(=>
            @setStateFromAccumulator()
        )
        @setStateFromAccumulator()

    componentWillUnmount: ->
        clearInterval(@updateInterval)
        @updateInterval = null

    setStateFromAccumulator: ->
        clockSkew.fetch((skew)=>
            t = Date.now() - skew
            @setState({
                accumulator: @accumulator
                polynomial: @accumulator.k
                value: Math.floor(@accumulator.evaluateAtTime(t))
            })
        )

    addOne: ->
        @accumulator.addPolynomial([1])

    addOnePerSecond: ->
        @accumulator.addPolynomial([0, 1])

    addOnePerSecondPerSecond: ->
        @accumulator.addPolynomial([0, 0, 1])

    toggleDiscrete: ->
        @accumulator.discrete = !@accumulator.discrete
        @setStateFromAccumulator()

    toggleBatched: ->
        @accumulator.batched = !@accumulator.batched
        @setStateFromAccumulator()

    reset: ->
        @accumulator.k = [0]
        @setStateFromAccumulator()

    save: ->
        localStorage.setItem(@props.saveKey, JSON.stringify(@accumulator))

    render: ->
        window.lastAI = this
        variable = 't'

        return <div>
            <var>f</var>(<var>t</var>)
            {' = '}
            <Polynomial variable={variable} coefficients={@state.polynomial} />
            {' = '}
            {@state.value}
            <br/>
            <br/>
            <button onClick={@addOne}>Add 1</button>
            <button onClick={@addOnePerSecond}>Add 1/sec</button>
            <button onClick={@addOnePerSecondPerSecond}>Add 1/sec<sup>2</sup></button>
            <button onClick={@reset}>Reset</button>
            <button onClick={@save}>Save</button>
            <br/>
            <label><input type="checkbox" onChange={@toggleDiscrete} checked={@state.accumulator.discrete} /> discrete</label>
            <label><input type="checkbox" onChange={@toggleBatched} checked={@state.accumulator.batched} /> batched</label>
        </div>
})

module.exports = AccumulatorInspector
