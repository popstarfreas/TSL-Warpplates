@unboxed
type t = {
    milliseconds: float,
}

let elapsed = (self: t): Time.t => {
    Time.fromMilliseconds(Js.Date.now() -. self.milliseconds)
}

let now = (): t => {
    milliseconds: Js.Date.now(),
}
