{request} = require('./util')

skew = null
callbacks = null

module.exports.fetch = (callback)->
    if skew
        return callback(skew)

    if callbacks
        callbacks.push(callback)
        return

    callbacks = [callback]
    skew = null
    clientTime = Date.now()
    request(document.location, {
        method: 'HEAD',
        headers: {'Cache-Control': 'no-cache'},
        onload: ->
            if (skew != null || this.status == 0)
                return

            serverTime = new Date(this.getResponseHeader('date'))
            # I don't think we have a way to tell how much time elapsed while the server was preparing the response.
            skew = (Date.now()+clientTime)/2 - serverTime

            for c in callbacks
                c(skew)
            callbacks = null
    })

module.exports.invalidate = ->
    skew = null

lastCheck = Date.now()
expectedDuration = 1000
checkTime = ->
    now = Date.now()
    duration = now - lastCheck
    lastCheck = now

    if Math.abs(duration - expectedDuration) > 1000
        console.log("Detected clock jump. Invalidating skew.", duration)
        skew = null

setInterval(checkTime, expectedDuration)
