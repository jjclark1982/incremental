{request} = require('./util')
clock = require('./clock')

skew = null
callbacks = null

fetch = (callback)->
    if skew
        return callback(skew)

    if callbacks
        callbacks.push(callback)
        return

    skew = null
    callbacks = [callback]

    clientTime = Date.now()
    request(document.location, {
        method: 'HEAD',
        headers: {'Cache-Control': 'no-cache'},
        onload: ->
            if (skew != null || this.status == 0)
                return

            serverTime = new Date(this.getResponseHeader('date'))
            skew = (Date.now()+clientTime)/2 - serverTime

            for callback in callbacks
                callback(skew)
            callbacks = null
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
