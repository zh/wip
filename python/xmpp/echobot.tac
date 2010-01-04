from twisted.application import service
from twisted.words.protocols.jabber import jid
from wokkel.component import Component

from echobot import EchoBotProtocol

application = service.Application("echobot")

xmppcomponent = Component("im.example.com", 5347, "echo.im.example.com", "pass")
xmppcomponent.logTraffic = False
echobot = EchoBotProtocol()
echobot.setHandlerParent(xmppcomponent)
xmppcomponent.setServiceParent(application)
