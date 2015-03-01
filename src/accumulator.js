function Accumulator(properties) {
    this.trustClientClock = false;
    this.discrete = true;
    this.batched = false;
    this.scale = 1000;
    this.t_0 = Date.now();
    this.k = [];
    for (var i in properties) {
        this[i] = properties[i];
    }
}

// number of widgets at time t = edp(poly, t, 0)
// number of widget factories at time t = edp(poly, t, 1)
// number of manually-bought factories = poly[1]
// TODO: do these equivalences still hold after translation?
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
    if (this.discrete) {
        return Math.floor(k_i);
    }
    else {
        return k_i;
    }
};

// general-purpose function to translate a polynomial from t_0 to t_1
// TODO: determine whether this method can accommodate higher-order polynomials
// f(t) = a * t^2 + b * t + c
// f(t-t_0) = a*(t-t_0)^2 + b*(t-t_0) + c
//          = a*(t^2 - 2*t_0*t + t_0^2) + b*t - b*t_0 + c
//          = a*t^2 - (2*a*t_0 + b)*t + a*t_0^2 - b*t_0 + c
// is t_0^2 meaningful?
Accumulator.prototype.translate = function(t_1) {
    var newPoly = [];
    for (var i = 0; i < this.k.length; i++) {
        // TODO: support higher order translation
        newPoly[i] = this.k[i];
    }
    var t = (t_1-this.t_0)/this.scale;
    newPoly[0] = this.evaluate(t);
    this.k = newPoly;
    this.t_0 = t_1;
};

// would like to support negative mods with floors
// eg consume materials to produce products,
// without going below zero
Accumulator.prototype.addPolynomial = function(mod) {
    if (skew == null && !this.trustClientClock) {
        var that = this;
        updateClockSkew(function(){
            that.addPolynomial(mod);
        });
    }
    else {
        var t_1 = Date.now() - skew;
        this.translate(t_1);
        mod = mod || [];
        for (var i = 0; i < mod.length; i++) {
            this.k[i] = (this.k[i] || 0) + mod[i];
        }
        // this.save();
    }
};

Accumulator.prototype.save = function() {
    // TBD
};

module.exports = Accumulator;
