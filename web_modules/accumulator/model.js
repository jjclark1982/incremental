var clockSkew = require('clock-skew');
var Polynomial = require('polynomial/model');

// Stateful class for managing a time-based formula
function Accumulator(properties) {
    for (var i in properties) {
        this[i] = properties[i];
    }
    this.t_0 = this.t_0 || Date.now();
    this.poly = Polynomial(this.poly);
}

// default options
Accumulator.prototype.trustClientClock = false;
Accumulator.prototype.scale = 1000;
Accumulator.prototype.discrete = true;
Accumulator.prototype.batched = false;
Accumulator.prototype.max = Infinity;
Accumulator.prototype.min = 0;

Accumulator.prototype.reset = function(k) {
    var self = this;
    clockSkew.fetch(function(skew){
        self.poly = Polynomial(k);
        self.t_0 = Date.now() - skew;
    });
}

// TODO: handle skew here so consumers don't have to
Accumulator.prototype.evaluateAtTime = function(t_1, i) {
    var t = (t_1-this.t_0)/this.scale;
    return this.poly.evaluate(t, i, this);
};

// first derivative of value
Accumulator.prototype.rateAtTime = function(t_1) {
    var t = (t_1-this.t_0)/this.scale;
    if (this.discrete) {
        return this.poly.numericRate(t, this);
    }
    else {
        var d = this.poly.derivative(this);
        return d.evaluate(t, 0, this);
    }
};

// For 'batched' accumulators, the progress until the next batch is complete.
Accumulator.prototype.progressAtTime = function(t_1) {
    if (this.poly.isConstant()) {
        return NaN;
    }
    var t = (t_1-this.t_0)/this.scale;
    return t - Math.floor(t);
};

// would like to support negative mods with floors
// eg consume materials to produce products, without going below zero
Accumulator.prototype.addPolynomial = function(rhs) {
    var self = this;
    rhs = Polynomial(rhs);
    if (rhs.isConstant()) { // bypass clock for constants
        self.poly = self.poly.addPolynomial(rhs);
        if (self.onChange) {
            self.onChange();
        }
        return;
    }
    clockSkew.fetch(function(skew){
        var t_1 = Date.now() - skew;
        var Dt = (t_1 - self.t_0) / self.scale;
        self.poly = self.poly.translate(Dt, self);
        self.poly = self.poly.addPolynomial(rhs);
        self.t_0 = t_1;

        // TODO: emit a proper change event
        if (self.onChange) {
            self.onChange();
        }
    });
};

module.exports = Accumulator;
