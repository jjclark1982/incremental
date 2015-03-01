$ = document.getElementById.bind(document);
$$ = document.querySelectorAll.bind(document);

function request(url, options) {
    options = options || {};
    var xhr = new XMLHttpRequest();
    // standard arguments get treated specially. here are their default values:
    var args = {
        method: 'GET',
        async: true,
        headers: {},
        body: null
    };
    // any additional options get set directly on xhr.
    // this allows the calling function to specify arbitrary parameters such as 'onload'.
    for (var i in options) {
        if (i in args) {
            args[i] = options[i];
        }
        else {
            xhr[i] = options[i];
        }
    }
    // serialize body as specified by Content-Type header
    if (args.body && typeof args.body !== 'string') {
        var contentType = args.headers['Content-Type'];
        if (contentType == 'application/json') {
            args.body = JSON.stringify(args.body);
        } else if (contentType == 'application/x-www-form-urlencoded') {
            args.body = serializeQuery(args.body);
        }
    }
    xhr.open(args.method, url, args.async);
    for (var name in args.headers) {
        var value = args.headers[name];
        xhr.setRequestHeader(name, value);
    }
    xhr.send(args.body);
    return xhr;
}

function serializeQuery(obj) {
    var pairs = [];
    for (var key in obj) {
        var value = obj[key];
        pairs.push(encodeURIComponent(key)+'='+encodeURIComponent(value));
    }
    return pairs.join('&').replace(/%20/g, '+')
}

function setText(field, value) {
    var props = ['value', 'textContent', 'innerText'];
    for (var i in props) {
        var prop = props[i];
        if (prop in field) {
            field[prop] = value;
            return
        }
    }
}

function render(template, context) {
    var container = document.createElement('div');
    var templateText = template.innerHTML || template;
    container.innerHTML = templateText.trim();
    var el = container.firstChild;
    for (var key in context) {
        var value = context[key];
        var selector = '[name="'+key+'"]';
        var fields = el.querySelectorAll(selector);
        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
            setText(field, value);
        }
    }
    return el;
}

module.exports = {
    $: $,
    $$: $$,
    request: request,
    serializeQuery: serializeQuery,
    setText: setText,
    render: render
};
