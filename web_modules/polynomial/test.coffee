expect = require('chai').expect

Polynomial = require('./model')

describe 'Polynomial', ->
    it 'should instantiate without errors', ->
        p = new Polynomial()
        p = new Polynomial([1])
        p = new Polynomial([1,2])

    it 'should evaluate an affine formula', ->
        p = new Polynomial([2,3])
        value = p.evaluate(4)
        expect(value).to.equal(3*4+2)
