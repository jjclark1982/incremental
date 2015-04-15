# Incremental

Experiments in closed-form tamper-resistant time-dependent formulas.

### Usage

To install dependencies:

    export PATH="$PATH:node_modules/.bin"
    npm install

To compile once, from `web_modules/` to `public/`:

    webpack

To serve static content from `public/`, and continuously compile and reload browsers whenever code changes:

    webpack-dev-server

To compile and commit `public/` to the `gh-pages` branch of the git repository:

    ./publish.sh

### Configuration

Compiler and server behavior can be controlled through environment variables:

 - `PORT=8080`: set the port the server listens on.

 - `NODE_ENV`: Set to `production` to minify built code. Defaults to `production` in `publish.sh` and `development` elsewhere.

### TODO

- unified controls for incrementing/decrementing each order of an accumulator's polynomial

- graph of value for each type


### Notes on "discrete" behavior

    f(x) = a + b*x + c*x^2 + d*x^3
        
          "widgets"            "factories"          "builders"   "firms"
    x     f(x)                 f‘(x)                f’’(x)       f’’’(x)
    -------------------------------------------------------------------------
    0     a                    b                    c            d
    0.5   a + ⌊0.5b⌋           b + ⌊0.5c⌋           c + ⌊0.5d⌋   d
    1     a + b                b + c                c + d        d
    1.5   a + ⌊1.5b⌋ + ⌊0.5c⌋  b + ⌊1.5c⌋ + ⌊0.5d⌋  c + ⌊1.5d⌋   d
    2     a + 2b + c           b + 2c + d           c + 2d       d
    1.5   a + ⌊2.5b⌋           b + ⌊1.5c⌋ + ⌊0.5d⌋  c + ⌊1.5d⌋   d
    3     a + 3b + 3c + d      b + 3c + 3d          c + 3d       d
    4     a + 4b + 6c + 4d     b + 4c + 6d          c + 4d       d
    5     a + 5b + 10c + 10d   b + 5c + 10d         c + 5d       d
    6     a + 6b + 15c + 20d   b + 6c + 15d         c + 6d       d
    7     a + 7b + 21c + 35d   b + 7c + 21d         c + 7d       d
    8     a + 8b + 28c + 56d   b + 8c + 28d         c + 8d       d
    9     a + 9b + 36c + 84d   b + 9c + 36d         c + 9d       d

    b sequence = 0,1,2,3,4,5,6 = lin(x) = x
    c sequence = 0,0,1,3,6,10,15,21,28,36 = tri(x-1) = C(x,2) = x(x-1)/2
    d sequence = 0,0,0,1,4,10,20,35,56,84 = tet(x-2) = C(x,3) = x(x-1)(x-2)/6


    x     a + ⌊C(x,1)*b⌋ + ⌊C(x,2)*c⌋ + ... + ⌊C(x,i)*k[i]⌋

    or when x < i:
        ⌊fpart(x)*k[i]⌋
    or when x < i-1:
        0
    so:
        c_i = Math.min(x+1-i, 0)

    f(x,n) := 0 when n > degree(f)
    f(x,i) := k_i + ⌊f(x-1,i+1)*x⌋
