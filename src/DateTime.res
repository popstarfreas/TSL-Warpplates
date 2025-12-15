@unboxed
type t = {
    milliseconds: float,
}

let elapsed = (self: t): Time.t => {
    Time.fromMilliseconds(Date.now() -. self.milliseconds)
}

let now = (): t => {
    milliseconds: Date.now(),
}
