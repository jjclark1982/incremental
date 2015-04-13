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
        p = new Polynomial([1,2,3])
        p2 = Polynomial(p)
        expect(p2).to.equal(p)

        p3 = p.clone()
        expect(p3).not.to.equal(p)
        expect(p3).to.deep.equal(p)

    it 'should serialize and deserialize without loss', ->
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

    it 'should sum multiple polynomials', ->
        p1 = new Polynomial([1,2,3])
        p2 = new Polynomial([0,4,5,6])
        expected = new Polynomial([1,6,8,6])

        p3 = Polynomial.sum([p1,p2])
        expect(p3).to.deep.equal(expected)

        p4 = p1.addPolynomial(p2)
        expect(p4).to.deep.equal(expected)

    describe 'should identify the degree of a formula', ->
        it 'constant', ->
            p = new Polynomial([1,0])
            expect(p.isConstant()).to.be.true
            expect(p.degree()).to.equal(0)

        it 'affine', ->
            p = new Polynomial([2,1,null])
            expect(p.degree()).to.equal(1)

        it 'quadratic', ->
            p = new Polynomial([3,2,1,])
            expect(p.degree()).to.equal(2)

        it 'cubic', ->
            p = new Polynomial([4,3,2,1])
            expect(p.degree()).to.equal(3)

    describe 'should evaluate a continuous formula', ->
        it 'constant', ->
            p = new Polynomial([2])
            expect(p.evaluate(0)).to.equal(2)
            expect(p.evaluate(5)).to.equal(2)
            expect(p.evaluate(5.1),0,{batched: true}).to.equal(2)
            expect(p.evaluate(5.1),0,{discrete: true}).to.equal(2)

        it 'affine', ->
            p = new Polynomial([2,3])
            value = p.evaluate(4)
            expect(value).to.equal(3*4 + 2)

        it 'quadratic', ->
            p = new Polynomial([2,3,4])
            value = p.evaluate(5)
            expect(value).to.equal(4*5*5 + 3*5 + 2)

        it 'cubic', ->
            p = new Polynomial([4,3,2,1])
            value = p.evaluate(5)
            expect(value).to.equal(5*5*5 + 2*5*5 + 3*5 + 4)

    describe 'should evaluate a bounded formula', ->
        it 'min', ->
            p = new Polynomial([3,2,1])
            value = p.evaluate(2, 0, {min: 100})
            expect(value).to.equal(100)

        it 'max', ->
            p = new Polynomial([3,2,1])
            value = p.evaluate(200, 0, {max: 100})
            expect(value).to.equal(100)

            p2 = new Polynomial([3,2,1])
            value2 = p2.evaluate(200, 0, {max: Infinity})
            expect(value2).to.equal(200*200 + 2*200 + 3)

            value3 = p2.evaluate(200, 0, {max: null})
            expect(value3).to.equal(200*200 + 2*200 + 3)

    describe 'should evaluate a batched formula', ->
        it 'constant', ->
            p = new Polynomial([2])
            expect(p.evaluate(3.9),0,{batched: true}).to.equal(2)

        it 'affine', ->
            p = new Polynomial([2,3])
            value = p.evaluate(4)
            value2 = p.evaluate(4.9, 0, {batched: true})
            expect(value2).to.equal(value)

        it 'quadratic', ->
            p = new Polynomial([2,3,4])
            value = p.evaluate(5)
            value2 = p.evaluate(5.9, 0, {batched: true})
            expect(value2).to.equal(value)

    describe 'should evaluate a discrete formula', ->
        it 'constant', ->
            p = new Polynomial([2])
            expect(p.evaluate(5.5),0,{discrete: true}).to.equal(2)

        it 'affine', ->
            p = new Polynomial([2,3])
            value = p.evaluate(4.5)
            value2 = p.evaluate(4.5, 0, {discrete: true})
            expect(value2).to.equal(value)

        it 'quadratic', ->
            p = new Polynomial([2,3,4])
            x = 5.7
            value = p.evaluate(x, 0, {discrete: true})
            expect(value).to.equal((Math.floor(4*x)+3)*x + 2)

    describe 'should translate to a new origin', ->
        it 'constant', ->
            p = new Polynomial([3])
            p2 = p.translate(4)
            value = p2.evaluate(5)
            expect(value).to.equal(3)

        it 'affine', ->
            p = new Polynomial([2,3])
            p2 = p.translate(5)
            value = p2.evaluate(3)
            expect(value).to.equal(3*8 + 2)

        it 'quadratic', ->
            p = new Polynomial([3,2,1])
            value = p.evaluate(5)
            expect(value).to.equal(5*5 + 2*5 + 3)

            p2 = p.translate(5)
            value2 = p2.evaluate(0)
            expect(value2).to.equal(value)

            value3 = p2.evaluate(3)
            expect(value3).to.equal(8*8 + 2*8 + 3)

        it 'cubic', ->
            p = new Polynomial([4,3,2,1])
            value = p.evaluate(5)
            expect(value).to.equal(5*5*5 + 2*5*5 + 3*5 + 4)

            p2 = p.translate(5)
            value2 = p2.evaluate(0)
            expect(value2).to.equal(value)

            value3 = p2.evaluate(3)
            expect(value3).to.equal(8*8*8 + 2*8*8 + 3*8 + 4)
