React = require('react')
Accumulator = require('./accumulator')
PolynomialView = require('./polynomial-view')
clockSkew = require('./clockSkew')
clock = require('./clock')

AccumulatorInspector = React.createClass({
    displayName: 'AccumulatorInspector'

    getInitialState: ->
        return {
            accumulator: {k: []}
            value: 0
        }

    componentWillMount: ->
        saveData = JSON.parse(localStorage.getItem(@props.saveKey))
        @accumulator = new Accumulator(saveData)
        @accumulator.onChange = =>
            @setStateFromAccumulator()
        clock.on('frame', @setStateFromAccumulator, @)
        @setStateFromAccumulator()

    componentWillUnmount: ->
        clearInterval(@updateInterval)
        @updateInterval = null

    setStateFromAccumulator: ->
        clockSkew.fetch((skew)=>
            t = Date.now() - skew
            @setState({
                accumulator: @accumulator
                t: t
                value: Math.floor(@accumulator.evaluateAtTime(t))
                rate: @accumulator.rateAtTime(t)
                progress: @accumulator.progressAtTime(t)
            })
        )

    # shouldComponentUpdate: (nextProps, nextState)->
    #     if nextState.value isnt @state.value
    #         return true
    #     if nextState.rate isnt @state.rate
    #         return true
    #     for k_i, i in nextState.accumulator?.k or []
    #         if @state.accumulator.k[i] isnt k_i
    #             return true
    #     return false

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

        if @state.progress
            progress = <progress value={@state.progress} max="1">{@state.progress*100|0} %</progress>

        return <div>
            <p className="math">
                <var>t</var><sub>0</sub>{' = '}
                {(new Date(@state.accumulator.t_0)).toString()}
            </p>
            <p className="math">
                <var>t</var><sub>1</sub>{' = '}
                {(new Date()).toString()}
            </p>
            <p className="math">
                Time scale: 1 tick = {@state.accumulator.scale} ms
            </p>
            <p className="math">
                <var>t</var> = <var>t</var><sub>1</sub> &ndash; <var>t</var><sub>0</sub>{' = '}
                {(@state.t - @state.accumulator.t_0)/ @state.accumulator.scale} ticks
            </p>
            <p className="math">
                Current value:{' '}
                <var>f</var>(<var>t</var>){' = '}
                <PolynomialView variable={variable} coefficients={@state.accumulator.k} />{' = '}
                {@state.value}
            </p>
            <p className="math">
                Current rate:{' '}
                <var>f&prime;</var>(<var>t</var>){' = '}
                {@state.rate} per tick
            </p>
            <p className="math">
                Progress: {progress}
            </p>
            <p>
                <button className="pure-button" onClick={@addOne}>Add 1</button>{' '}
                <button className="pure-button" onClick={@addOnePerSecond}>Add 1/sec</button>{' '}
                <button className="pure-button" onClick={@addOnePerSecondPerSecond}>Add 1/sec<sup>2</sup></button>{' '}
                <button className="pure-button" onClick={@reset}>Reset</button>{' '}
                <button className="pure-button" onClick={@save}>Save</button>
            </p>
            <p>
                <label className="pure-checkbox"><input type="checkbox" onChange={@toggleDiscrete} checked={@state.accumulator.discrete} /> discrete</label>{' '}
                <label className="pure-checkbox"><input type="checkbox" onChange={@toggleBatched} checked={@state.accumulator.batched} /> batched</label>
            </p>
        </div>
})

module.exports = AccumulatorInspector
