var gamma = require('gamma');

// factorial approximation
function fact(n) {
    return gamma(n+1);
}

function lnFact(n) {
    return gamma.log(n+1);
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
    return n - Math.floor(n);
}

// binomial coefficient
function C(n, k) {
    if (n < 16 && isInt(n) && isInt(k)) {
        return discreteC(n, k);
    }
    else {
        return numericC(n, k);
    }
}

function discreteC(n, k) {
    if (k <= 0 || k >= n) {
        return 1;
    }
    // find exact answer recursively, using a cache
    discreteC.cache[n] = discreteC.cache[n] || [];
    if (discreteC.cache[n][k] != null) {
        return discreteC.cache[n][k];
    }
    var result = discreteC(n-1, k-1) + discreteC(n-1, k);
    discreteC.cache[n][k] = result;
    return result;
}
discreteC.cache = [];

function numericC(n, k) {
    if (n > 100) {
        (fact(n) / fact(n-k)) / fact(k)
    }
    // var approx = fact(n) / ( fact(k) * fact(n-k) );
    var approx = Math.exp(lnFact(n) - lnFact(k) - lnFact(n-k));
    if (isInt(n) && isInt(k)) {
        return Math.round(approx);
    }
    else {
        return approx;
    }
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

Polynomial.prototype.scale = function(s) {
    var newK = [];
    for (var i = 0; i < this.k.length; i++) {
        newK[i] = s * this.k[i];
    }
    return new Polynomial(newK);
};

Polynomial.prototype.mult = function(rhs) {
    rhs = Polynomial(rhs);
    var result = [];
    for (var i = 0; i < this.k.length; i++) {
        var k_i = this.k[i];
        for (var j = 0; j < rhs.k.length; j++) {
            var k_j = rhs.k[j];
            var exp = i + j;
            result[exp] = (result[exp] || 0) + k_i*k_j;
        }
    }
    return new Polynomial(result);
}

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

Polynomial.prototype.pow = function(exp) {
    var degree = this.degree();
    if (degree == 0) {
        return Math.pow(this.k[0], exp);
    }
    else if (degree == 1) {
        // binomial: find coefficients of (a*x + b)^exp
        var a = this.k[1];
        var b = this.k[0];
        var k = [];
        for (var i = 0; i <= exp; i++) {
            // coefficient of x^i: a^i * C(exp, i) * b^{exp-i}
            k[i] = Math.pow(a,i) * discreteC(exp, i) * Math.pow(b, exp-i);
        }
        return new Polynomial(k)
    }
    else {
        throw new Error("not implemented")
    }
}

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
Polynomial.prototype.evaluate = function(x, options, i) {
    options = options || {};
    i = i || 0;
    if (i >= this.k.length || i < 0 || !isInt(i)) {
        return 0;
    }
    if (options.batched) {
        x = Math.floor(x);
    }
    var j = i + 1;
    var k_j = this.evaluate(x, options, j);
    var k_i;
    if (options.discrete) {
        if (options.very_discrete && i > 0) {
            k_j = Math.floor(k_j);
        }
        var c_i;
        if (i == 0) {
            c_i = 1;
        }
        else {
            c_i = Math.max(0, numericC(x,i));
        }
        k_i = c_i*this.k[i] + k_j;
    }
    else {
        k_i = this.k[i] + k_j*x;
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
        // for each offest term (x + Δx)^i
        // find k_i * (x + Δx)^i
        var term = Polynomial([Δx, 1]).pow(i).scale(k_i);
        terms.push(term);
    }
    var result = Polynomial.sum(terms);
    // hack to ensure continuity in other modes
    result.k[0] = this.evaluate(Δx, options);
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
    var delta = 1/256;
    var val1 = this.evaluate(x, options);
    var val2 = this.evaluate(x+delta, options);
    var epsilon = val2 - val1;
    return epsilon/delta;
};

module.exports = Polynomial;
