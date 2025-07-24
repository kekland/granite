#!/usr/bin/env node

const path = require('path');
const util = require('util');
const fs = require('fs');
const exec = require('child_process').exec;

const scriptLocation = path.resolve(__dirname);
const rootLocation = path.resolve(scriptLocation, '..', '..');
const generatedLocation = path.resolve(rootLocation, 'lib', 'vector_tile', 'gen');
const protoPath = path.resolve(rootLocation, 'references', 'vector_tile');

// Delete and re-create the generated directory
if (fs.existsSync(generatedLocation)) fs.rmSync(generatedLocation, { recursive: true });
fs.mkdirSync(generatedLocation, { recursive: true });

const command = `protoc --dart_out=${generatedLocation} --proto_path=${protoPath} vector_tile.proto`;
exec(command, (error, stdout, stderr) => {
  if (error) {
    console.error(`Error generating Dart code: ${error.message}`);
    return;
  }
  if (stderr) {
    console.error(`Error output: ${stderr}`);
    return;
  }
  console.log(`Dart code generated successfully:\n${stdout}`);
});
