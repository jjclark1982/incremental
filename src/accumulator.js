clockSkew = require('./clockSkew');

function Accumulator(properties) {
    this.t_0 = Date.now();
    this.k = [0];
    for (var i in properties) {
        this[i] = properties[i];
    }
}

// default values
Accumulator.prototype.trustClientClock = false;
Accumulator.prototype.discrete = true;
Accumulator.prototype.batched = false;
Accumulator.prototype.scale = 1000;
Accumulator.prototype.max = Infinity;
Accumulator.prototype.min = 0;

// number of widgets at time t = evaluate(poly, t, 0)
// number of widget factories at time t = evaluate(poly, t, 1)
// number of manually-bought factories = poly[1]
// these equivalences still hold after first-order translation,
// but not higher-order translation.
Accumulator.prototype.evaluate = function(x, i) {
    i = i || 0;
    if (i >= this.k.length) {
        return 0;
    }
    if (this.batched) {
        x = Math.floor(x);
    }
    var j = i + 1;
    var k_j = this.evaluate(x, j);
    var k_i = this.k[i] + k_j*x;
    if (this.discrete && i != 0) {
        // fractional amounts are useful for translation, so keep them at the very end
        k_i = Math.floor(k_i);
    }
    if (i == 0) {
        if (this.max == null) {
            this.max = Infinity;
        }
        if (this.min == null) {
            this.min = -Infinity;
        }
        return Math.max(Math.min(k_i, this.max), this.min);
    }
    else {
        return k_i;
    }
};

// TODO: handle skew here so consumers don't have to
Accumulator.prototype.evaluateAtTime = function(t_1, i) {
    var t = (t_1-this.t_0)/this.scale;
    value = this.evaluate(t, i);
    return Math.min(this.max, value);
};

// first derivative of value
Accumulator.prototype.rateAtTime = function(t_1) {
    var t = (t_1-this.t_0)/this.scale;
    return this.evaluate(t, 1);
};

// For 'batched' accumulators, the progress until the next batch is complete.
Accumulator.prototype.progressAtTime = function(t_1) {
    if (this.isConstant()) {
        return NaN;
    }
    var t = (t_1-this.t_0)/this.scale;
    return t - Math.floor(t);
};

Accumulator.prototype.degree = function() {
    var degree = 0;
    for (var i = 0; i < this.k.length; i++) {
        var k_i = this.k[i];
        if (k_i) {
            degree = i;
        }
    }
    return degree;
};

Accumulator.prototype.isConstant = function() {
    return (this.degree() == 0);
};

// general-purpose function to translate a polynomial from t_0 to t_1
// this discards information about manually-entered values.
Accumulator.prototype.translate = function(t_1) {
    var t = (t_1-this.t_0)/this.scale;
    var newK = [];
    for (var i = 0; i < this.k.length; i++) {
        newK[i] = this.evaluate(t, i);
    }
    this.k = newK;
    this.t_0 = t_1;
};

// would like to support negative mods with floors
// eg consume materials to produce products,
// without going below zero
Accumulator.prototype.addPolynomial = function(mod) {
    var self = this;
    if (mod.length == 1) { // bypass clock for constants
        self.k[0] = (self.k[0] || 0) + mod[0];
        if (self.onChange) {
            self.onChange();
        }
        return;
    }
    clockSkew.fetch(function(skew){
        var t_1 = Date.now() - skew;
        self.translate(t_1);
        mod = mod || [];
        for (var i = 0; i < mod.length; i++) {
            self.k[i] = (self.k[i] || 0) + mod[i];
        }

        // TODO: emit a proper change event
        if (self.onChange) {
            self.onChange();
        }
    });
};

module.exports = Accumulator;
