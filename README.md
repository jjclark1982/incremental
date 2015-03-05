# Incremental

Experiments in closed-form tamper-resistant time-dependent formulas.

### Usage

To install dependencies:

    export PATH="$PATH:node_modules/.bin"
    npm install

To compile once, from `src/` to `public/`:

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
