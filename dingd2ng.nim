import irc, asyncdispatch, strutils
import htmltitle, unicode

proc onIrcEvent(client: AsyncIrc, event: IrcEvent) {.async.} =
  case event.typ
  of EvConnected:
    discard
  of EvDisconnected, EvTimeout:
    await client.reconnect()
  of EvMsg:
    if event.cmd == MPrivMsg:
      var msg = event.params[event.params.high]
      if msg == "!test": await client.privmsg(event.origin, "hello")
      if msg == "!lag":
        await client.privmsg(event.origin, formatFloat(client.getLag))
      if unicode.toLower(msg).contains("http"):
        for part in msg.split(' '):
          if unicode.toLower(part).startsWith("http"):
            let title = htmltitle.readTitle(part)
            if title!=nil:
              await client.privmsg(event.origin, title)
    echo(event.raw)

var client = newAsyncIrc("chat.freenode.net", nick="dingd2ng",
                 joinChans = @["#yfb"], callback = onIrcEvent)
asyncCheck client.run()

runForever()