import { nodeResolve } from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';
// var external = require('@yelo/rollup-node-external');

export default {
  input: 'lib/js/src/Index.js',
  output: {
    dir: 'output',
    format: 'cjs'
  },
  external: ['redis', 'terrariaserver-lite', 'terrariaserver-lite/lib/js/src/TerrariaServerLite.js'],
  plugins: [json(), commonjs(), nodeResolve()]
};
