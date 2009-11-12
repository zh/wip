#!/usr/bin/env python

import os
import sys, resource

from twisted.internet import reactor
from twisted.web import proxy, server
from twisted.web.resource import Resource
from twisted.web.server import NOT_DONE_YET
from twisted.application import service, internet
from twisted.python import log

# Add current path to Python path
sys.path.insert(0, os.path.abspath(os.path.dirname(".")))

FRONT_PORT = 8080
BACK_URL = 'www.yahoo.com'
BACK_PORT = 80
CFG_FILE= 'myproxy.cfg'

class MyProxyResource(proxy.ReverseProxyResource):
  def __init__(self, host=BACK_URL, port=BACK_PORT, path="", reactor=reactor):
    Resource.__init__(self)
    self.host = host
    self.port = port
    self.path = path
    self.reactor = reactor

class MyProxy(internet.TCPServer):
  def __init__(self):
    internet.TCPServer.__init__(self, FRONT_PORT, server.Site(MyProxyResource()))

if __name__ == "__builtin__":
  resource.setrlimit(resource.RLIMIT_NOFILE, (1024, 1024))
  application = service.Application("myproxy")
  try:
    config = eval(open(CFG_FILE).read())
    print config
    proxy = MyProxy()
    proxy.setServiceParent(application)
  except:
    print "Please fix/create your config file"	  
else:
  print "Please start using: twistd --reactor=epoll -noy myproxy.py"
