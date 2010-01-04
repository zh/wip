from twisted.words.xish import domish
from wokkel.xmppim import MessageProtocol, AvailablePresence

class EchoBotProtocol(MessageProtocol):
    def __init__(self, component=False):
        MessageProtocol.__init__(self)
        self.component = component

    def connectionMade(self):
        print "Connected!"

        # send initial presence we're a client
        if not self.component:
            self.send(AvailablePresence())

    def connectionLost(self, reason):
        print "Disconnected!"

    def onMessage(self, msg):
        print str(msg)

        if msg["type"] == 'chat' and hasattr(msg, "body"):
            reply = domish.Element((None, "message"))
            reply["to"] = msg["from"]
            reply["from"] = msg["to"]
            reply["type"] = 'chat'
            reply.addElement("body", content="echo: " + str(msg.body))

            self.send(reply)

