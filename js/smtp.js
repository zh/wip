/*

  smtpd.js is SMTP server written for node.js

  MIT License
*/

var tcp = require('net');
var sys = require('sys');

var enable_debug = true;

var server = tcp.createServer( function( socket ) {
  var eol = "\r\n";

  // patterns for commands
  var command_patterns = {
    helo: /^HELO\s*/i,
    ehlo: /^EHLO\s*/i,
    quit: /^QUIT/i,
    from: /^MAIL FROM:\s*/i,
    rcpt: /^RCPT TO:\s*/i,
    data: /^DATA/i,
    noop: /^NOOP/i,
    rset: /^RSET/i,
    vrfy: /^VRFY\s+/i,
    expn: /^EXPN\s+/,
    help: /^HELP/i,
    tls: /^STARTTLS/i,
    auth: /^AUTH\s+/i
  }

  // our replies
  var reply = {
    send: function(s) {
      debug( "reply: '" + (s || "null") + "'" );
      socket.send( s + eol );
    },
    banner: function() {
      reply.send("220 <hostname> ESMTP smtpd.js");
    },
    error: function(s) {
      reply.send("500 " + s);
    },
    ok: function() {
      reply.send("250 OK");
    }
  }

  function Command( line ) {

    function parseCommand( line ) {

      for( var cmd in command_patterns) {
        if (command_patterns[ cmd ].test( buffer ) ) {

          return cmd;
        }
      }
    }

    function extractArguments( command ) {
      return this.line.replace( command, '' ).replace(/^\s\s*/, '').replace(/\s\s*$/, '');
    }

    this.cmd = parseCommand( line ).toLowerCase();
    this.line = line;
    this.in_data = false;
    this.data = [];

    this.isRecognized = function() {
      return typeof this.cmd != "undefined";
    }

    this.exec = function() {
      if ( callbacks[this.cmd] ) {
        callbacks[this.cmd].callback(this.line);
      }
      else {
        reply.error("command not implemented");
      }
    }

    var that = this;

    var callbacks = {
      quit: {
        callback: function () {
          reply.send( '221 <hostname> closing connection' );
          socket.close();
        }
      },
      ehlo: {
        callback: function() {
          var hostname = extractArguments( 'EHLO' );
          reply.send('250-<hostname> Hello ' + socket.remoteAddress );
          reply.send('250 8BITMIME');
        }
      },
      helo: {
        callback: function() {
          reply.send('250 <hostname> Hello ' + socket.remoteAddress );
        }
      },
      from: {
        callback: function() {
          this.from = extractArguments( 'MAIL FROM:' );
          reply.ok();
        }
      },
      rcpt: {
        callback: function() {
          this.recipient = extractArguments( 'RCPT TO:' );
          reply.ok();
        }
      },
      data: {
        callback: function() {
          that.in_data = true;
          reply.send("354 Terminate with line containing only '.'");
        }
      }
    }

    this.appendData = function( buffer ) {
      var size = buffer.length;
      var line = "";

      for( var i = 0; i < buffer.length; i++ ){
        var chr = buffer[i];

        if( chr + buffer[i + 1] == eol ) {
          this.data.push( line );
          line = "";
          i++;
          continue;
        }

        line += chr;
      }

      var size = this.data.length - 1;

      if( this.data[size] == '.' && this.data[size - 1] == '' ) {
        this.in_data = false;
        this.data.pop();
        this.data.pop();
      }
    }

    return this;
  }

  function debug(s) {
    if( enable_debug && s != null ) {
      sys.print( s.toString() + eol );
      sys.print('----------------------------' + eol );
    }
  }

  socket.addListener('connect', function() {
    reply.banner();
  });

  var buffer = "";
  var cmd = {};

  socket.addListener('receive', function(packet) {
    buffer += packet;

    while( buffer.indexOf(eol) != -1 ) {

      if ( cmd.in_data ) {

        cmd.appendData( buffer );

        // we're finished
        if( !cmd.in_data ) {
          reply.ok();
        }
      }
      else {

        cmd = Command( buffer );

        if ( cmd.isRecognized() ) {
          cmd.exec();
        } else {
          reply.error('unrecognized command');
        }
      }

      buffer = "";
    }
  });

  socket.addListener('eof', function(){
    socket.close();
  });
});

exports.runServer = function() {
  server.listen( 10025 );
}

