React = require('react')
numbro = require('numbro')

Numeral = React.createClass({
    displayName: 'Numeral'

    propTypes: {
        value: React.PropTypes.number
    }

    render: ->
        if !@props.value? or isNaN(@props.value)
            return <span />

        n = numbro(@props.value)
        magnitude = Math.abs(@props.value)

        if @props.format?
            display = n.format(@props.format)
        else if magnitude < 10
            display = n.format('0[.][000]')
        else if magnitude < 100
            display = n.format('0[.][00]')
        else if magnitude < 1000
            display = n.format('0[.]0')
        else if magnitude < 10000
            display = n.format('0,0')
        else if magnitude < 1e15
            display = n.format('0,0.000a')
            if display.length > 6
                display = n.format('0,0.00a')
                if display.length > 6
                    display = n.format('0,0.0a')
        else
            display = n.value().toExponential().replace(/(\d\.\d\d\d)[^e]*/,'$1')
            display = display.replace('Infinity', '∞')

        return <span>{display}</span>
})

module.exports = Numeral
