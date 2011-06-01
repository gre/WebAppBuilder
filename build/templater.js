#!/usr/bin/env node

var Mu = require("./lib/mu");
var print = require("sys").print;
var options;
try {
  options = eval('('+process.argv[3]+')');
}
catch(e) {
  console.error('warning: incorrect template arguments: '+e);
  console.error('Your options was: "'+process.argv[3]+'"');
  options = {};
}

Mu.templateExtension=null;
Mu.render(process.argv[2], options, {}, function (err, output) {
  if (err) throw err;
  output.addListener('data', function (c) { print(c) });
});
