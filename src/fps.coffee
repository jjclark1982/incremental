clockSkew = require('./clockSkew')

startTime = Date.now()

fps = {
    msOnPage: 0

    targetFPS: null
    targetMsec: null

    displayInterval: null
    setTarget: (targetFPS)->
        @targetFPS = targetFPS
        @targetMsec = 1000 / targetFPS
        clearInterval(@displayInterval)
        @displayInterval = setInterval(=>
            requestAnimationFrame(@tick.bind(this))
        , @targetMsec)

    measuredFPS: null
    measuredMsec: null
    lastFrame: Date.now()
    callbacks: []
    tick: ->
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

window.FPS = fps
fps.setTarget(12)

module.exports = fps
