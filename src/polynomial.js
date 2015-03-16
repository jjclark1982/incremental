// find coefficients of (x + b)^exp
function evaluateBinomial(b, exp) {
    var k = [];
    for (var i = 0; i <= exp; i++) {
        k[i] = binomialC(exp, i) * Math.pow(b, exp-i)
    }
    return new Polynomial(k)
}
function binomialC(n, k) {
    _cachedBC[n] = _cachedBC[n] || [];
    if (_cachedBC[n][k] != null) {
        return _cachedBC[n][k];
    }
    _cachedBC[n][k] = computeBinomialC(n, k);
    return _cachedBC[n][k];
}
var _cachedBC = [];
function computeBinomialC(n, k) {
    if (k <= 0 || k >= n) {
        return 1;
    }
    return binomialC(n-1, k-1) + binomialC(n-1, k);
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
Polynomial.prototype.evaluate = function(x, i, options) {
    options = options || {};
    i = i || 0;
    if (i >= this.k.length) {
        return 0;
    }
    if (options.batched) {
        x = Math.floor(x);
    }
    var j = i + 1;
    var k_j = this.evaluate(x, j, options);
    if (options.discrete) {
        k_j = Math.floor(k_j);
    }
    var k_i = this.k[i] + k_j*x;
    if (i == 0) {
        var max = options.max == null ?  Infinity : options.max;
        var min = options.min == null ? -Infinity : options.min;
        return Math.max(Math.min(k_i, max), min);
    }
    else {
        return k_i;
    }
};

// Translate a function f(x) to a new origin: f(x + Dx).
// ideally evaluate(t, 1) has the same result before and afterwards.
Polynomial.prototype.translate = function(Dx, options) {
    var currentRates = [];
    for (var i = 0; i < this.k.length; i++) {
        currentRates[i] = this.evaluate(Dx, i, options);
    }
    return new Polynomial(currentRates);

    // this was causing the current rate to change
    // var result = new Polynomial();// this.multiplyByScalar(-1);
    // for (var i = 0; i < this.k.length; i++) {
    //     var k_i = this.k[i];
    //     // k_i * (x + Dx)^i
    //     var termToPower = evaluateBinomial(Dx, i).multiplyByScalar(k_i);
    //     result = result.addPolynomial(termToPower);
    // }
    // return result;
};

module.exports = Polynomial;
