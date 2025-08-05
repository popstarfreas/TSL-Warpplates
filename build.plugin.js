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

console.log("Build Step 1 of 4")
child_process.execSync("pnpm i --production=true ../../pluginreference", { stdio: "inherit" })
console.log("Build Step 2 of 4")
child_process.execSync("pnpm run build:core", { stdio: "inherit" })
console.log("Build Step 3 of 4")
child_process.execSync("pnpm run build:packed", { stdio: "inherit" })
console.log("Build Step 4 of 4")
fs.renameSync("./output", "./plugin")
