expect = require('chai').expect

Polynomial = require('./model')

describe 'Polynomial', ->
    it 'should instantiate without errors', ->
        p = new Polynomial()
        expect(p).instanceof(Polynomial)
        p2 = new Polynomial([])
        p3 = new Polynomial([1])
        p4 = new Polynomial([1,2])
        p5 = new Polynomial([1,2,0])
        p6 = new Polynomial([1,2,null])
        p7 = new Polynomial([null,2])

    it 'should clone other polynomials', ->
        p = new Polynomial()
        p2 = Polynomial(p)
        expect(p2).to.equal(p)

    it 'should serialize and deserialize to the same value', ->
        p = new Polynomial([1,2,3])
        json = JSON.stringify(p)
        obj = JSON.parse(json)
        p2 = Polynomial(obj)
        expect(p2).to.deep.equal(p)

    it 'should multiply by scalars', ->
        p = new Polynomial([1,2,3])
        p2 = p.multiplyByScalar(4)
        value = p.evaluate(5)
        expect(value).to.equal(3*5*5 + 2*5 + 1)
        value2 = p2.evaluate(5)
        expect(value2).to.equal(4*value)

    it 'should identify a constant formula', ->
        p = new Polynomial([1,0])
        expect(p.isConstant()).to.be.true
        degree = p.degree()
        expect(degree).to.equal(0)

    it 'should evaluate a constant formula', ->
        p = new Polynomial([2])
        expect(p.evaluate(0)).to.equal(2)
        expect(p.evaluate(5)).to.equal(2)
        expect(p.evaluate(5.1),0,{batched: true}).to.equal(2)
        expect(p.evaluate(5.1),0,{discrete: true}).to.equal(2)

    it 'should translate a constant formula', ->
        p = new Polynomial([3])
        p2 = p.translate(4)
        value = p2.evaluate(5)
        expect(value).to.equal(3)

    it 'should identify an affine formula', ->
        p = new Polynomial([2,3,0])
        degree = p.degree()
        expect(degree).to.equal(1)

    it 'should evaluate an affine formula', ->
        p = new Polynomial([2,3])
        value = p.evaluate(4)
        expect(value).to.equal(3*4 + 2)

    it 'should evaluate an affine formula in batched mode', ->
        p = new Polynomial([2,3])
        value = p.evaluate(4)
        value2 = p.evaluate(4.9, 0, {batched: true})
        expect(value2).to.equal(value)

    it 'should evaluate an affine formula in discrete mode', ->
        p = new Polynomial([2,3])
        value = p.evaluate(4.5)
        value2 = p.evaluate(4.5, 0, {discrete: true})
        expect(value2).to.equal(value)

    it 'should translate an affine formula', ->
        p = new Polynomial([2,3])
        p2 = p.translate(5)
        value = p2.evaluate(4)
        expect(value).to.equal(3*(4+5) + 2)

    it 'should evaluate a quadratic formula', ->
        p = new Polynomial([2,3,4])
        value = p.evaluate(5)
        expect(value).to.equal(4*5*5 + 3*5 + 2)

    it 'should evaluate a quadratic formula in batched mode', ->
        p = new Polynomial([2,3,4])
        value = p.evaluate(5)
        value2 = p.evaluate(5.9, 0, {batched: true})
        expect(value2).to.equal(value)

    it 'should evaluate a quadratic formula in discrete mode', ->
        p = new Polynomial([2,3,4])
        x = 5.7
        value = p.evaluate(x, 0, {discrete: true})
        expect(value).to.equal((Math.floor(4*x)+3)*x + 2)

    it 'should translate a quadratic formula', ->
        p = new Polynomial([3,2,1])
        value = p.evaluate(5)
        expect(value).to.equal(5*5 + 2*5 + 3)

        p2 = p.translate(5)
        value2 = p2.evaluate(0)
        expect(value2).to.equal(value)

        value3 = p2.evaluate(3)
        expect(value3).to.equal(8*8 + 2*8 + 3)

    it 'should evaluate a cubic formula', ->
        p = new Polynomial([4,3,2,1])
        value = p.evaluate(5)
        expect(value).to.equal(5*5*5 + 2*5*5 + 3*5 + 4)

    it 'should translate a cubic formula', ->
        p = new Polynomial([4,3,2,1])
        value = p.evaluate(5)
        expect(value).to.equal(5*5*5 + 2*5*5 + 3*5 + 4)

        p2 = p.translate(5)
        value2 = p2.evaluate(0)
        expect(value2).to.equal(value)

        value3 = p2.evaluate(3)
        expect(value3).to.equal(8*8*8 + 2*8*8 + 3*8 + 4)
