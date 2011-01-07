var spawn = require('child_process').spawn,
     fs = require('fs'),
     sys = require('sys');

 function ssh(username, host, file) {
   fs.readFile(file, function (err, data) {
     if (err) throw err;

     var hasPassword = false;
     var commands = data.toString().split('\n').join(' && ');
     var ssh = spawn('ssh', ['-l' + username, host, commands]);

     ssh.on('exit', function (code, signal) {
       process.exit();
     });

     ssh.stdout.on('data', function (out) {
       process.stdout.write(out);
       if (!hasPassword) {
         var stdin = process.openStdin();
         stdin.on('data', function (chunk) {
           ssh.stdin.write(chunk);
         });
       }

       hasPassword = true;
     });

     ssh.stderr.on('data', function (err) {
       process.stdout.write(err);
     });  
   });
 };

 var args = process.argv.slice(2);
 sys.puts('Running commands from ' + args[1] + ' as root@' + args[0]);
 ssh('root', args[0], args[1]);
