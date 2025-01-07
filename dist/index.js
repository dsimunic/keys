const throttle = (func, limit) => {
    let lastFunc
    let lastRan
    return function () {
        const context = this
        const args = arguments
        if (!lastRan) {
            func.apply(context, args)
            lastRan = Date.now()
        } else {
            clearTimeout(lastFunc)
            lastFunc = setTimeout(function () {
                if ((Date.now() - lastRan) >= limit) {
                    func.apply(context, args)
                    lastRan = Date.now()
                }
            }, limit - (Date.now() - lastRan))
        }
    }
}

let map = new WeakMap();
let orig = document.addEventListener.bind(document);
document.addEventListener = (t, h, o) => {
    console.log("Called addEventListener override")
    if (t === 'mousemove') {
        let throttled = throttle(h, 32);
        map.set(h, throttled);
        return orig(t, throttled, o)
    }
    else
        return orig(t, h, o)
}

let orig2 = document.removeEventListener.bind(document);
document.removeEventListener = (t, h, o) => {
    console.log("Called removeEventListener override")
    let h2 = map.get(h);
    if (h2) {
        map.delete(h);
        return orig2(t, h2, o);
    }
    else
        return orig2(t, h, o);
}

const elm = Elm.Main.init({
    node: document.getElementById('root'),
    flags: window.location.hostname
});
