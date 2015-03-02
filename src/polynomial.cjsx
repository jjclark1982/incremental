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
        # console.log("rendering polynomial", @props.coefficients)
        variable = @props.variable or 'x'
        terms = []
        for k_i, i in @props.coefficients
            if i > 0
                if !k_i
                    continue
                terms.push(" + ")
            terms.push(<Term key={i} k={k_i} exp={i} variable={variable} />)
        terms.reverse()

        return <span>{terms}</span>
})

module.exports = Polynomial
