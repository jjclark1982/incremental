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
    if (k instanceof Polynomial) {
        this.k = k.k;
    }
    else {
        this.k = k || [0];
    }
}

Polynomial.prototype.toJSON = function() {
    return this.k;
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

Polynomial.prototype.addPolynomial = function(rhs) {
    var rhk = new Polynomial(rhs).k;
    var newK = [];
    var length = Math.max(this.k.length, rhk.length);
    for (var i = 0; i < length; i++) {
        newK[i] = (this.k[i] || 0) + (rhk[i] || 0);
    }
    return new Polynomial(newK);
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
    var k_i = this.k[i] + k_j*x;
    if (options.discrete && i != 0) {
        // fractional amounts are useful for translation, so keep them at the very end
        k_i = Math.floor(k_i);
    }
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
// TODO: discrete and batched behavior for this operation.
Polynomial.prototype.translate = function(Dx) {
    var result = new Polynomial();
    for (var i = 0; i < this.k.length; i++) {
        var k_i = this.k[i];
        var termToPower = evaluateBinomial(Dx, i).multiplyByScalar(k_i);
        result = result.addPolynomial(termToPower);
    }
    return result;
};

module.exports = Polynomial;
