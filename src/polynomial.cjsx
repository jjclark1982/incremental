React = require('react')

Term = React.createClass({
    displayName: 'Term'
    render: ->
        if @props.k != 1 or @props.exp is 0
            coefficient = @props.k
        if @props.exp > 0
            variable = @props.variable or 'x'
        if @props.exp > 1
            exponent = @props.exp

        return <span>{coefficient}<var>{variable}</var><sup>{exponent}</sup></span>
})

Polynomial = React.createClass({
    displayName: 'Polynomial'

    render: ->
        variable = @props.variable or 'x'
        terms = []
        for k_i, i in @props.coefficients when k_i
            if terms.length > 0
                terms.push(' + ')
            terms.push(<Term key={i} k={k_i} exp={i} variable={variable} />)
        if terms.length is 0
            terms.push('0')
        terms.reverse()

        return <span>{terms}</span>
})

module.exports = Polynomial
