try
    require('file?name=test.html!./test.html')

expect = require('chai/chai.js').expect

describe 'The frontend testing harness', ->
    it 'should load in a browser environment', ->
        expect(window?).to.be.true
