type t
let zero: t
let make: (~days: int=?, ~hours: int=?, ~minutes: int=?, ~seconds: int=?, ~milliseconds: int=?, unit) => t
let format: t => string
let fromMilliseconds: float => t
let minus: (t, t) => t
let smallerThan: (t, t) => bool
let greaterThan: (t, t) => bool
