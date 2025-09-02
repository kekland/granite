#!/usr/bin/env node

const path = require('path');
const util = require('util');
const fs = require('fs');
const exec = require('child_process').exec;

const scriptLocation = path.resolve(__dirname);
const rootLocation = path.resolve(scriptLocation, '..', '..');
const generatedLocation = path.resolve(rootLocation, 'lib', 'glyphs', 'gen');
const protoPath = path.resolve(rootLocation, 'references', 'glyphs');

// Delete and re-create the generated directory
if (fs.existsSync(generatedLocation)) fs.rmSync(generatedLocation, { recursive: true });
fs.mkdirSync(generatedLocation, { recursive: true });

const command = `protoc --dart_out=${generatedLocation} --proto_path=${protoPath} glyphs.proto`;
exec(command);
