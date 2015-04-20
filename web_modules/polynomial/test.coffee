expect = require('chai').expect
gamma = require('gamma')
Polynomial = require('./model')

[a, b, c, d] = []
ipart = (n)->
    if n >= 0
        Math.floor(n)
    else
        Math.ceil(n)

describe 'Polynomial', ->
    beforeEach(->
        [a, b, c, d] = [4.4, 3.3, 2.2, 1.1]
    )

    it 'should instantiate without errors', ->
        p = new Polynomial()
        expect(p).instanceof(Polynomial)
        p2 = new Polynomial([])
        p3 = new Polynomial([1])
        p4 = new Polynomial([1,2])
        p5 = new Polynomial([1,2,0])
        p6 = new Polynomial([1,2,null])
        p7 = new Polynomial([null,2])
        p8 = new Polynomial(3,4)

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
        p2 = p.mult(4)
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

    it 'should identify the degree of a formula', ->
        p0 = new Polynomial([1,0])
        expect(p0.isConstant()).to.be.true
        expect(p0.degree()).to.equal(0)

        p1 = new Polynomial([2,1,null])
        expect(p1.degree()).to.equal(1)

        p2 = new Polynomial([3,2,1,])
        expect(p2.degree()).to.equal(2)

        p3 = new Polynomial([4,3,2,1])
        expect(p3.degree()).to.equal(3)

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
            expect(value).to.equal(2 + 3*4)

        it 'quadratic', ->
            p = new Polynomial([c,b,a])
            x = 5.5
            value = p.evaluate(x)
            expect(value).to.equal(c + b*x + a*x*x)

        it 'cubic', ->
            p = new Polynomial([a,b,c,d])
            x = 5
            value = p.evaluate(x)
            expect(value).to.equal(a + b*x + c*x*x + d*x*x*x)

        it 'negative', ->
            p = new Polynomial([a,b,-c,d])
            x = 5.5
            value = p.evaluate(x)
            expect(value).to.equal(a + b*x + -c*x*x + d*x*x*x)

    describe 'should evaluate a bounded formula', ->
        it 'min', ->
            p = new Polynomial([3,2,1])
            value = p.evaluate(2, {min: 100})
            expect(value).to.equal(100)

        it 'max', ->
            p = new Polynomial([3,2,1])
            value = p.evaluate(200, {max: 100})
            expect(value).to.equal(100)

            p2 = new Polynomial([3,2,1])
            value2 = p2.evaluate(200, {max: Infinity})
            expect(value2).to.equal(3 + 2*200 + 1*200*200)

            value3 = p2.evaluate(200, {max: null})
            expect(value3).to.equal(3 + 2*200 + 1*200*200)

        it 'min and max', ->
            p = new Polynomial([3,2,1])
            value = p.evaluate(2000, {min: 50, max: 100})
            expect(value).to.equal(100)

            value = p.evaluate(1, {min: 50, max: 100})
            expect(value).to.equal(50)


    describe 'should evaluate a batched formula', ->
        it 'constant', ->
            p = new Polynomial([2])
            value = p.evaluate(3.9, {batched: true})
            expect(value).to.equal(2)

        it 'affine', ->
            p = new Polynomial([2,3])
            value = ipart(p.evaluate(4))
            value2 = ipart(p.evaluate(4.2, {batched: true}))
            expect(value2).to.equal(value)

        it 'quadratic', ->
            p = new Polynomial([c,b,a])
            x = 5.5
            value = p.evaluate(x, {batched: true})
            expect(value).to.equal(c + ipart(b + ipart(a)*x)*x)

        it 'cubic', ->
            p = new Polynomial([a,b,c,d])
            x = 6.6
            value = p.evaluate(x, {batched: true})
            expect(value).to.equal(a + ipart(b + ipart(c + ipart(d)*x)*x)*x)

        it 'negative', ->
            p = new Polynomial([a,b,-9*c,d])
            x = 7.7
            value = p.evaluate(x, {batched: true})
            expect(value).to.equal(a + ipart(b + ipart(-9*c + ipart(d)*x)*x)*x)

    describe 'should evaluate a discrete formula', ->
        it 'constant', ->
            p = new Polynomial([2.2])
            value = p.evaluate(5.5, {discrete: true})
            expect(value).to.equal(2.2)

        it 'affine', ->
            p = new Polynomial([c, b])
            x = 4.5
            value = p.evaluate(x, {discrete: true})
            expected = c + b*x
            expect(Math.abs(value-expected)).to.be.lessThan(0.00001)

        it 'quadratic', ->
            p = new Polynomial([c,b,a])
            x = 5 # f(5) = a + 5b + 10c
            value = p.evaluate(x, {discrete: true})
            expect(value).to.equal(c + (5*b) + (10*a))

            value2 = p.evaluate(x+0.1, {discrete: true})
            expect(value2).to.be.greaterThan(value)
            value3 = p.evaluate(x-0.1, {discrete: true})
            expect(value3).to.be.lessThan(value)

            expect(value).not.to.equal(p.evaluate(x))

        it 'cubic', ->
            p = new Polynomial([a,b,c,d])
            x = 4 # f(4) = a + 4b + 6c + 4d
            value = p.evaluate(x, {discrete: true})
            expect(value).to.equal(a + (4*b) + (6*c) + (4*d))

            value2 = p.evaluate(x+0.1, {discrete: true})
            expect(value2).to.be.greaterThan(value)
            value3 = p.evaluate(x-0.1, {discrete: true})
            expect(value3).to.be.lessThan(value)

            expect(value).not.to.equal(p.evaluate(x))

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
            expect(value).to.equal(2 + 3*8)

        it 'quadratic', ->
            p = new Polynomial([3,2,1])
            x = 5
            value = p.evaluate(x)
            expect(value).to.equal(3 + 2*x + 1*x*x)

            p2 = p.translate(x)
            value2 = p2.evaluate(0)
            expect(value2).to.equal(value)

            b = 8
            value3 = p2.evaluate(b - x)
            expect(value3).to.equal(b*b + 2*b + 3)

        it 'cubic', ->
            p = new Polynomial([4,3,2,1])
            x = 5
            value = p.evaluate(x)
            expect(value).to.equal(4 + 3*x + 2*x*x + 1*x*x*x)

            p2 = p.translate(x)
            value2 = p2.evaluate(0)
            expect(value2).to.equal(value)

            b = 8
            value3 = p2.evaluate(b - x)
            expect(value3).to.equal(4 + 3*b + 2*b*b + 1*b*b*b)

        it 'discrete', ->
            p = new Polynomial([4,3,2,1])
            options = {discrete: true}
            x = 5
            value = p.evaluate(x, options)
            expect(value).to.equal(4 + 3*5 + 2*10 + 10*1)

            p2 = p.translate(x, options)
            value2 = p2.evaluate(0, options)
            expect(value2).to.equal(value)

            b = 8
            value3 = p2.evaluate(b-x, options)
            value4 = p.evaluate(b, options)
            expect(value3).to.equal(value4)

            rate1 = p.numericRate(x+0.5, options)
            rate2 = p2.numericRate(0.5, options)
            expect(Math.abs(rate2-rate1)).to.be.lessThan(0.1)

    describe 'should evaluate the derivative of a polynomial', ->
        it 'constant', ->
            p = new Polynomial([2])
            rate = p.derivative().evaluate(5)
            expect(rate).to.equal(0)

        it 'affine', ->
            p = new Polynomial([1,2])
            rate = p.derivative().evaluate(5)
            expect(rate).to.equal(2)

        it 'quadratic', ->
            p = new Polynomial([3,2,1])
            x = 5
            rate = p.derivative().evaluate(x)
            expect(rate).to.equal(2*x + 2)

        it 'cubic', ->
            p = new Polynomial([4,3,2,1])
            x = 5
            rate = p.derivative().evaluate(x)
            expect(rate).to.equal(3*x*x + 4*x + 3)
