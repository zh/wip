#!/usr/bin/env python

from twisted.web.http import HTTPClient
from twisted.web.client import HTTPClientFactory
from twisted.web import server, resource, error, http
from twisted.internet import reactor
from twisted.python import log
import simplejson as json
from twisted.web import client

import pygtk
pygtk.require('2.0')
import pynotify

import sys

def sendNotify(notice):
  n = None
  msg = notice['text']
  title = "notify.io message"
  if 'title' in notice:
    title = notice['title']
  if 'link' in notice:
    msg += "\nLink: <a href=\"%s\">%s</a>" %  (notice['link'], notice['link'])
  if 'icon' in notice:
    n = pynotify.Notification(title, msg, notice['icon'])
  else:
    n = pynotify.Notification(title, msg)
  n.set_urgency(pynotify.URGENCY_NORMAL)
  n.set_timeout(5000) # 5 seconds
  if not n.show():
    print "Failed to send notification"

            
class CometStream(HTTPClient):
    stream = 0
    
    def sendCommand(self, command, path):
        self.transport.write('%s %s HTTP/1.1\r\n' % (command, path))
    
    def lineReceived(self, line):
        if not self.stream:
            if line == "":
                self.stream = 1
        else:
            try:
                if '{' in line:
                    notice = json.loads(line)
                    sendNotify(notice)
                    print notice
            except ValueError, e:
                pass
        
    def connectionMade(self):
        self.sendCommand('GET', self.factory.path)
        self.sendHeader('Host', 'api.notify.io')
        self.sendHeader('User-Agent', self.factory.agent)
        self.endHeaders()
        print "Connected and receiving..."

class CometFactory(HTTPClientFactory):
    protocol = CometStream

if __name__ == '__main__':
  if not pynotify.init("Notify.io"):
    sys.exit(1)
    
  log.startLogging(sys.stdout)
  f = CometFactory('http://api.notify.io/v1/listen/{__USERHASH__}?api_key={__APIKEY__}')
  reactor.connectTCP('api.notify.io', 80, f)
  reactor.run()
