React = require('react')
Accumulator = require('accumulator/model')
PolynomialView = require('polynomial/view')
Numeral = require('numeral')
clockSkew = require('clock-skew')
clock = require('clock')

require('chart.js')
LineChart = require('react-chartjs').Line

AccumulatorView = React.createClass({
    displayName: 'AccumulatorView'

    getInitialState: ->
        return {
            autoSave: true
            accumulator: new Accumulator()
            value: 0
            chartData: {
                labels: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                datasets: [
                    label: "Value"
                    data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                ]
            }
        }

    componentWillMount: ->
        try
            saveData = JSON.parse(localStorage.getItem(@props.saveKey))
        @accumulator = new Accumulator(saveData)
        @accumulator.onChange = =>
            @setStateFromAccumulator()
            if @state.autoSave
                @save()
        clock.on('frame', @setStateFromAccumulator, @)
        @setStateFromAccumulator()

    componentWillUnmount: ->
        clearInterval(@updateInterval)
        @updateInterval = null

    setStateFromAccumulator: ->
        clockSkew.fetch((skew)=>
            t_1 = Date.now() - skew
            t = (t_1 - @accumulator.t_0) / @accumulator.scale
            value = Math.floor(@accumulator.evaluateAtTime(t_1))
            chartData = @state.chartData
            @frame ?= 0
            if @frame++ % 16 is 0
                chartData.datasets[0].data.shift()
                chartData.datasets[0].data.push(value)
                chartData.labels.shift()
                chartData.labels.push(t_1)
            @setState({
                accumulator: @accumulator
                t_1: t_1
                t: t
                value: value
                rate: @accumulator.rateAtTime(t_1)
                progress: @accumulator.progressAtTime(t_1)
                chartData: chartData
                skew: skew
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

    toggleAutoSave: ->
        @setState({
            autoSave: !@state.autoSave
        })

    reset: ->
        @accumulator.reset()
        @setStateFromAccumulator()

    save: ->
        localStorage.setItem(@props.saveKey, JSON.stringify(@accumulator))

    render: ->
        window.lastAI = this
        variable = 't'

        chartOptions = {
            bezierCurve: false
        }

        if @state.progress
            progress = <progress value={@state.progress} max="1">{@state.progress*100|0} %</progress>

        return <div>
            <p className="math">
                <var>t</var><sub>0</sub> = 
                {(new Date(@state.accumulator.t_0)).toString()}
            </p>
            <p className="math">
                <var>t</var><sub>1</sub> = 
                {(new Date()).toString()}
            </p>
            <p className="math">
                Clock skew: <Numeral value={@state.skew}/> ms
            </p>
            <p className="math">
                Time scale: 1 tick = 
                <Numeral value={@state.accumulator.scale}/> ms
            </p>
            <p className="math">
                <var>t</var> = <var>t</var><sub>1</sub> &ndash; <var>t</var><sub>0</sub> = 
                <Numeral value={@state.t} format='0,0[.][0]'/> ticks
            </p>
            <p className="math">
                Current value: 
                <var>f</var>(<var>t</var>) = 
                <PolynomialView poly={@accumulator.poly} variable={variable} /> = 
                <Numeral value={@state.value}/>
            </p>
            <p className="math">
                Current rate: 
                <var>f&prime;</var>(<var>t</var>) = 
                <Numeral value={@state.rate}/> per tick
            </p>
            <p className="math">
                Progress: {progress}
            </p>
            <p>
                <button className="pure-button" onClick={@addOne}>Add 1</button>{' '}
                <button className="pure-button" onClick={@addOnePerSecond}>Add 1/sec</button>{' '}
                <button className="pure-button" onClick={@addOnePerSecondPerSecond}>Add 1/sec<sup>2</sup></button>{' '}
                <button className="pure-button" onClick={@reset}>Reset</button>{' '}
                <button className="pure-button" onClick={@save}>Save</button>{' '}
                <label className="pure-checkbox"><input type="checkbox" onChange={@toggleAutoSave} checked={@state.autoSave} />auto-save</label> 
            </p>
            <p>
                <label className="pure-checkbox"><input type="checkbox" onChange={@toggleDiscrete} checked={@state.accumulator.discrete} /> discrete</label>{' '}
                <label className="pure-checkbox"><input type="checkbox" onChange={@toggleBatched} checked={@state.accumulator.batched} /> batched</label>
            </p>
            <LineChart data={@state.chartData} options={chartOptions} width={600} height={250}/>
        </div>
})

module.exports = AccumulatorView
