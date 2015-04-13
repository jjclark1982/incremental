#!/usr/bin/env NODE_PATH=web_modules mocha --compilers coffee:coffee-script/register

testFiles = require('./index')

describe 'The backend testing harness', ->
    describe 'should compile tests without errors', ->
        for file in testFiles then do (file)->
            it file, ->
                require(file)
