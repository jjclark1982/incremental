React = require('react')

Term = React.createClass({
    displayName: 'Term'
    render: ->
        coefficient = @props.k

        if !@props.initial
            if coefficient < 0
                coefficient = -coefficient
                op = <span>&ndash;</span>
            else
                op = '+'

        if coefficient is 1 and @props.exp isnt 0
            coefficient = ''
        if coefficient is -1
            coefficient = '-'

        if @props.exp > 0
            variable = @props.variable or 'x'

        if @props.exp > 1
            exponent = @props.exp

        return <span> {op} {coefficient}<var>{variable}</var><sup>{exponent}</sup></span>
})

Polynomial = React.createClass({
    displayName: 'Polynomial'

    render: ->
        variable = @props.variable or 'x'
        terms = []
        for k_i, i in @props.coefficients when k_i
            initial = (i is @props.coefficients.length - 1)
            term = <Term key={i} k={k_i} exp={i} variable={variable} initial={initial}/>
            terms.push(term)
        if terms.length is 0
            terms.push('0')
        terms.reverse()

        return <span>{terms}</span>
})

module.exports = Polynomial
