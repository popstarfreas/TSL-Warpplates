var child_process = require("child_process")
var fs = require("fs")

child_process.execSync("npm run build:submodule")
child_process.execSync("npm run build:core")
child_process.execSync("npm run build:packed")
fs.renameSync("./output", "./plugin")
