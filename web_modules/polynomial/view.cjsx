React = require('react')
Numeral = require('numeral')

Term = React.createClass({
    displayName: 'Term'
    render: ->
        coefficient = @props.k

        # all terms but the first one have a plus or minus operator
        if !@props.initial
            if coefficient < 0
                coefficient = -coefficient
                op = <span>&ndash;</span>
            else
                op = '+'

        # all terms but the constant have optional coefficients
        if @props.exp isnt 0
            if coefficient is 1
                coefficient = ''
            if coefficient is -1
                coefficient = '-'

        if @props.exp > 0
            variable = @props.variable or 'x'

        if @props.exp > 1
            exponent = @props.exp

        if typeof coefficient isnt 'string'
            coefficient = <Numeral value={coefficient}/>

        return <span> {op} {coefficient}<var>{variable}</var><sup>{exponent}</sup></span>
})

PolynomialView = React.createClass({
    displayName: 'PolynomialView'

    render: ->
        variable = @props.variable or 'x'
        terms = []
        degree = @props.poly.degree()
        for k_i, i in @props.poly.k when k_i
            initial = (i is degree)
            term = <Term key={i} k={k_i} exp={i} variable={variable} initial={initial}/>
            terms.push(term)
        if terms.length is 0
            terms.push(<Term key={0} k={0} initial={true}/>)
        terms.reverse()

        return <span>{terms}</span>
})

module.exports = PolynomialView
