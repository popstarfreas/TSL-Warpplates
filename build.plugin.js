var child_process = require("child_process")
var fs = require("fs")
var path = require("path")

console.log("Build Step 1 of 5")
child_process.execSync("rm package.json")
child_process.execSync("rm package-lock.json")
child_process.execSync("mkdir node_modules")
child_process.execSync("npm i --no-package-lock --no-save rollup@2.41.0")
child_process.execSync("npm i --no-package-lock --no-save @rollup/plugin-commonjs@17.1.0")
child_process.execSync("npm i --no-package-lock --no-save @rollup/plugin-json@4.1.0")
child_process.execSync("npm i --no-package-lock --no-save @rollup/plugin-node-resolve@11.2.0")
console.log("Build Step 2 of 5")
child_process.execSync("cp -r ../../pluginreference ./node_modules/terrariaserver-lite")
console.log("Build Step 3 of 5")
child_process.execSync("../../node_modules/bs-platform/bsb -make-world")
console.log("Build Step 4 of 5")
child_process.execSync("node_modules/rollup/dist/bin/rollup -c")
fs.renameSync("./output/Index.js", "./output/index.js")
console.log("Build Step 5 of 5")
fs.renameSync("./output", "./plugin")
