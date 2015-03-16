EventEmitter = require('./event-emitter')

class Clock extends EventEmitter
    constructor: (options)->
        for key, val of options
            this[key] = val
        @startTime ?= Date.now()
        @lastFrame ?= Date.now()
        if @targetFPS
            @setTargetFPS(@targetFPS)

    startTime: null
    msOnPage: 0

    targetFPS: null
    targetMsec: null

    displayInterval: null
    setTargetFPS: (targetFPS)->
        @targetFPS = targetFPS
        clearInterval(@displayInterval)
        if targetFPS > 0
            @targetMsec = Math.floor(1000 / targetFPS)
            @displayInterval = setInterval(@tick.bind(@), @targetMsec)
            @tick()

    frameRequest: null
    tick: ->
        @now = Date.now()
        @msOnPage = @now - @startTime
        @trigger("tick")
        if !@frameRequest
            @frameRequest = requestAnimationFrame(@frame.bind(@))

    measuredFPS: null
    measuredMsec: null
    lastFrame: null
    msecForThisFrame: null
    frame: ->
        @frameRequest = null

        @msecForThisFrame = @now - @lastFrame
        @lastFrame = @now

        @measuredMsec ?= @msecForThisFrame
        @measuredMsec = (0.125 * @msecForThisFrame) + (0.875 * @measuredMsec)
        @measuredFPS = 1000 / @measuredMsec

        @trigger("frame")

module.exports = new Clock({
    targetFPS: 30
})

if window.clock
    window.clock.setTargetFPS(0)

window.clock = module.exports
