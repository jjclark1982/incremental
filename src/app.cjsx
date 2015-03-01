React = require('react')
Polynomial = require('./polynomial')

IncrementalApp = React.createClass({
    displayName: 'IncrementalApp'

    render: ->
        # this is not usually visible

        return <div>
            <h1>Incremental</h1>
            <Polynomial variable="t" coefficients={[1,2,3]} />
        </div>
})

module.exports = IncrementalApp
