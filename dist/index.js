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

let orig = document.addEventListener;
document.addEventListener = (t, h, o) => {
    console.log("Called addEventListener override")
    if (t === 'mousemove')
        return orig(t, throttle(h, 32), o)
    else
        return orig(t, h, o)
}

const elm = Elm.Main.init({
    node: document.getElementById('root'),
    flags: window.location.hostname
});
