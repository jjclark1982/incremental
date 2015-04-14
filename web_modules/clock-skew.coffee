{request} = require('util')
clock = require('clock')

skew = null
callbacks = null

fetch = (callback)->
    if skew isnt null
        return callback?(skew)

    if callbacks isnt null
        callbacks.push(callback)
        return

    skew = null
    callbacks = [callback]

    handleError = (error)->
        reportResults(NaN)

    reportResults = (value)->
        skew = value
        for callback in callbacks
            callback?(skew)
        callbacks = null

    clientTime = Date.now()
    request(document.location, {
        method: 'HEAD',
        headers: {'Cache-Control': 'no-cache'},
        onerror: handleError
        onload: ->
            # already answered
            if skew isnt null
                return

            # something wrong
            if @status is 0
                return handleError()

            # clientTime = (Date.now() + clientTime)/2
            clientTime = Date.now()
            serverTime = new Date(this.getResponseHeader('date'))

            # server time not supported
            if !serverTime
                return reportResults(0)

            reportResults(clientTime - serverTime)
    })

invalidate = ->
    skew = null

clock.on('frame', ->
    if Math.abs(clock.msecForThisFrame - clock.targetMsec) > 1000
        invalidate()
)

module.exports = {
    fetch: fetch
    invalidate: invalidate
}

window.clockSkew = module.exports
