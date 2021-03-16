@unboxed
type t = {
    milliseconds: float,
}

let secondsToMilliseconds = (seconds: int): float =>
    (seconds->Belt.Int.toFloat) *. 1000.0
let minutesToMilliseconds = (minutes: int): float =>
    (minutes->Belt.Int.toFloat) *. secondsToMilliseconds(60)
let hoursToMilliseconds = (hours: int): float =>
    (hours->Belt.Int.toFloat) *. minutesToMilliseconds(60)
let daysToMilliseconds = (days: int): float =>
    (days->Belt.Int.toFloat) *. hoursToMilliseconds(24)

let format = (self: t): string => {
    let days = Belt.Float.toInt(self.milliseconds /. daysToMilliseconds(1))
    let milliseconds = self.milliseconds -. daysToMilliseconds(days)
    let hours = Belt.Float.toInt(milliseconds /. hoursToMilliseconds(1))
    let milliseconds = milliseconds -. hoursToMilliseconds(hours)
    let minutes = Belt.Float.toInt(milliseconds /. minutesToMilliseconds(1))
    let milliseconds = milliseconds -. minutesToMilliseconds(minutes)
    let seconds = Belt.Float.toInt(milliseconds /. secondsToMilliseconds(1))
    let formattedTime = ref("")
    if days > 0 {
        let prefix = formattedTime.contents->Js.String2.length > 0 ? " " : ""
        let suffix = days > 1 ? "s" : ""
        formattedTime.contents = `${prefix}${days->Belt.Int.toString} day${suffix}`
    }

    if hours > 0 {
        let prefix = formattedTime.contents->Js.String2.length > 0 ? " " : ""
        let suffix = hours > 1 ? "s" : ""
        formattedTime.contents = formattedTime.contents ++ `${prefix}${hours->Belt.Int.toString} hour${suffix}`
    }

    if minutes > 0 {
        let prefix = formattedTime.contents->Js.String2.length > 0 ? " " : ""
        let suffix = minutes > 1 ? "s" : ""
        formattedTime.contents = formattedTime.contents ++ `${prefix}${minutes->Belt.Int.toString} minute${suffix}`
    }

    if seconds > 0 {
        let prefix = formattedTime.contents->Js.String2.length > 0 ? " " : ""
        let suffix = seconds > 1 ? "s" : ""
        formattedTime.contents = formattedTime.contents ++ `${prefix}${seconds->Belt.Int.toString} second${suffix}`
    }

    formattedTime.contents
}

let make = (
    ~days: int = 0,
    ~hours: int = 0,
    ~minutes: int = 0,
    ~seconds: int = 0,
    ~milliseconds: int = 0,
    ()
): t => {
    let milliseconds = daysToMilliseconds(days)
    +. hoursToMilliseconds(hours)
    +. minutesToMilliseconds(minutes)
    +. secondsToMilliseconds(seconds)
    +. milliseconds->Belt.Int.toFloat

    {
        milliseconds,
    }
}

let greaterThan = (a: t, b: t): bool => {
    a.milliseconds > b.milliseconds
}

let smallerThan = (a: t, b: t): bool => {
    a.milliseconds < b.milliseconds
}

let fromMilliseconds = (a: float): t => {
    milliseconds: a,
}

let minus = (self: t, a: t): t => {
    {
        milliseconds: self.milliseconds -. a.milliseconds,
    }
}

let zero = {
    milliseconds: 0.0,
}
