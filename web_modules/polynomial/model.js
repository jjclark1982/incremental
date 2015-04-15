var gamma = require('gamma');

// factorial approximation
function fact(n) {
    return gamma(n+1);
}

function isInt(n) {
    return n === (n|0);
}

function round(n, figures) {
    figures = figures || 0;
    var scale = Math.pow(10,figures+1);
    return Math.round(n*scale)/scale;
}

function fpart(n) {
    return n - Math.round(n);
}

// binomial coefficient
function C(n, k) {
    if (k <= 0 || k >= n) {
        return 1;
    }
    if (n < 16 && isInt(n) && isInt(k)) {
        // find exact answer recursively, using a cache
        C.cache[n] = C.cache[n] || [];
        if (C.cache[n][k] != null) {
            return C.cache[n][k];
        }
        var result = C(n-1, k-1) + C(n-1, k);
        C.cache[n][k] = result;
        return result;
    }
    else {
        // find approximate answer
        return numC(n, k);
    }
}
C.cache = [];

function numC(n, k) {
    var approx = fact(n) / ( fact(k) * fact(n-k) );
    if (isInt(n) && isInt(k)) {
        return Math.round(approx);
    }
    else {
        return approx;
    }
}

// find coefficients of (x + b)^exp
function evaluateBinomial(b, exp) {
    var k = [];
    for (var i = 0; i <= exp; i++) {
        k[i] = C(exp, i) * Math.pow(b, exp-i)
    }
    return new Polynomial(k)
}

// Polynomial is an immutable class representing a single-variable polynomial.
// It is represented as an array of coefficients k[],
// such that f(x) = k_i * x^i + ... + k_0
function Polynomial(k) {
    // support using the constructor to quickly ensure type.
    if (k instanceof Polynomial) {
        return k;
    }
    // support using the constructor without the 'new' keyword.
    if (!(this instanceof Polynomial)) {
        return new Polynomial(k);
    }
    else {
        // initialization
        this.k = k || [];
        return this;
    }
}

Polynomial.prototype.toJSON = function() {
    return this.k;
}

Polynomial.prototype.clone = function() {
    var newK = [];
    for (var i = 0; i < this.k.length; i++) {
        newK[i] = this.k[i];
    }
    return new Polynomial(newK);
}

Polynomial.prototype.degree = function() {
    var degree = 0;
    for (var i = 0; i < this.k.length; i++) {
        var k_i = this.k[i];
        if (k_i) {
            degree = i;
        }
    }
    return degree;
};

Polynomial.prototype.isConstant = function() {
    return (this.degree() == 0);
};

Polynomial.prototype.multiplyByScalar = function(s) {
    var newK = [];
    for (var i = 0; i < this.k.length; i++) {
        newK[i] = s * this.k[i];
    }
    return new Polynomial(newK);
};

Polynomial.sum = function(polys) {
    var k = [];
    polys = polys || [];
    for (var i = 0; i < polys.length; i++) {
        var p = Polynomial(polys[i]);
        for (var j = 0; j < p.k.length; j++) {
            k[j] = (k[j] || 0) + p.k[j];
        }
    }
    return new Polynomial(k);
};

Polynomial.prototype.addPolynomial = function(rhs) {
    return Polynomial.sum([this, rhs]);
};

// number of widgets at time t = evaluate(poly, t, 0)
// number of widget factories at time t = evaluate(poly, t, 1)
// number of manually-bought factories = poly[1]
// these equivalences still hold after first-order translation,
// but not higher-order translation.
// discrete formula for a + b*x^2 + c*x^3 + ...:
// f(x) := a + ⌊C(x,1)*b⌋ + ⌊C(x,2)*c⌋ + ... + ⌊C(x,i)*k[i]⌋
Polynomial.prototype.evaluate = function(x, i, options) {
    options = options || {};
    i = i || 0;
    if (i >= this.k.length || i < 0 || !isInt(i)) {
        return 0;
    }
    if (options.batched) {
        x = Math.floor(x);
    }
    var j = i + 1;
    var k_j = this.evaluate(x, j, options);
    var k_i;
    if (options.discrete) {
        var c_i;
        if (i == 0) {
            c_i = 1;
        }
        else {
            c_i = Math.max(numC(x,i), 0);
        }
        k_i = c_i*this.k[i] + k_j;
    }
    else {
        var k_i = this.k[i] + k_j*x;
    }
    if (i == 0) {
        if (options.precision) {
            k_i = round(k_i, options.precision);
        }
        var max = options.max == null ?  Infinity : options.max;
        var min = options.min == null ? -Infinity : options.min;
        return Math.max(Math.min(k_i, max), min);
    }
    else {
        return k_i;
    }
};

// Translate a function f(x) to a new origin:
// F(x) == f(x + Δx)
// F‘(x) == f‘(x + Δx)
// see http://math.stackexchange.com/questions/1179086/translation-of-a-polynomial
Polynomial.prototype.translate = function(Δx, options) {
    var terms = [];
    for (var i = 0; i < this.k.length; i++) {
        var k_i = this.k[i];
        // k_i * (x + Δx)^i
        var termToPower = evaluateBinomial(Δx, i).multiplyByScalar(k_i);
        terms.push(termToPower);
    }
    var result = Polynomial.sum(terms);
    // hack to ensure continuity in other modes
    result.k[0] = this.evaluate(Δx, 0, options);
    return result;
};

Polynomial.prototype.derivative = function(options) {
    var k = [0];
    for (var i = 1; i < this.k.length; i++) {
        k[i-1] = i * this.k[i];
    }
    return new Polynomial(k);
};

Polynomial.prototype.numericRate = function(x, options) {
    var v1 = this.evaluate(x-0.125, 0, options);
    var v2 = this.evaluate(x+0.125, 0, options);
    return (v2-v1)/0.25;
};

module.exports = Polynomial;
