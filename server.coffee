#!/usr/bin/env NODE_PATH=web_modules coffee

# example of isomorphic react rendering

require('coffee-react/register')

React = require('react')
App = require('./web_modules/main/app')

Polynomial = require('polynomial/model')
PolynomialView = require('polynomial/view')

p = new Polynomial([2,3,4])
pv = React.createElement(PolynomialView, {poly: p})
html = React.renderToString(pv)

process.stdout.write(html)
