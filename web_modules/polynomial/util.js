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

function ipart(n) {
    if (n >= 0) {
        return Math.floor(n);
    }
    else {
        return Math.ceil(n);
    }
}

function fpart(n) {
    return n - ipart(n);
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
    // extending range to 0 appears to keep things continuous
    if (k <= -1 || k >= n+1) {
        return 0;
    }
    var approx;
    if (n < 100) {
        // more accurate for small numbers
        approx = fact(n) / (fact(k) * fact(n-k));
    }
    else {
        // keep large numbers in mantissa
        approx = Math.exp(lnFact(n) - lnFact(k) - lnFact(n-k));
    }
    if (isInt(n) && isInt(k)) {
        return Math.round(approx);
    }
    else {
        return approx;
    }
}

module.exports = {
    gamma: gamma,
    fact: fact,
    lnFact: lnFact,
    isInt: isInt,
    round: round,
    ipart: ipart,
    fpart: fpart,
    C: C,
    discreteC: discreteC,
    numericC: numericC
};
