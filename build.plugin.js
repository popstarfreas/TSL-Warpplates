var child_process = require("child_process")
var fs = require("fs")
var path = require("path")

function copyDir(src, dest) {
    fs.mkdirSync(dest, { recursive: true });
    let entries = fs.readdirSync(src, { withFileTypes: true });

    for (let entry of entries) {
        let srcPath = path.join(src, entry.name);
        let destPath = path.join(dest, entry.name);

        entry.isDirectory() ?
            copyDir(srcPath, destPath) :
            fs.copyFileSync(srcPath, destPath);
    }
}

console.log("Build Step 1 of 5")
child_process.execSync("npm i")
console.log("Build Step 2 of 5")
copyDir("../../pluginreference", "./node_modules/terrariaserver-lite")
console.log("Build Step 3 of 5")
child_process.execSync("npm run build:core")
console.log("Build Step 4 of 5")
child_process.execSync("npm run build:packed:minimal")
fs.renameSync("./output/Index.js", "./output/index.js")
console.log("Build Step 5 of 5")
fs.renameSync("./output", "./plugin")
