listenerID = 0

module.exports = class EventEmitter
    events: null

    on: (name, handler, listener)->
        listener ?= ++listenerID
        @events ?= {}
        @events[name] ?= []
        @events[name].push({
            handler: handler
            listener: listener
        })
        return listener

    trigger: (name, args...)->
        @events ?= {}
        for item in @events[name] or []
            item.handler.call(item.listener, args...)

    stopListening: (listener)->
        @events ?= {}
        for name in Object.keys(@events)
            @events[name] = (item for item in @events[name] when item.listener isnt listener)
