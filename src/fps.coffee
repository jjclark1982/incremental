clockSkew = require('./clockSkew')

startTime = Date.now()

fps = {
    msOnPage: 0

    targetFPS: null
    targetMsec: null

    displayInterval: null
    setTarget: (targetFPS)->
        @targetFPS = targetFPS
        @targetMsec = Math.floor(1000 / targetFPS)
        clearInterval(@displayInterval)
        @displayInterval = setInterval(@tick.bind(@), @targetMsec)

    frameRequested: false
    tick: ->
        if !@frameRequested
            requestAnimationFrame(@frame.bind(@))
            @frameRequested = true

    measuredFPS: null
    measuredMsec: null
    lastFrame: Date.now()
    callbacks: []
    frame: ->
        @frameRequested = false

        now = Date.now()
        @msOnPage = now - startTime

        msecForThisFrame = now - @lastFrame
        @lastFrame = now

        @measuredMsec ?= msecForThisFrame
        @measuredMsec = (0.125 * msecForThisFrame) + (0.875 * @measuredMsec)
        @measuredFPS = 1000 / @measuredMsec

        if Math.abs(msecForThisFrame - @targetMsec) > 1000
            clockSkew.invalidate()

        for callback in @callbacks
            callback?()
}

fps.setTarget(12)

module.exports = fps
