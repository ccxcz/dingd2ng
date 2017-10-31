import irc, asyncdispatch, strutils
import htmltitle, unicode

import strutils
import docopt

let doc = """
dingd2ng IRC Bot. 
Defaults to chat.freenode.net with nick dingd2ng in channel #yfb

Usage:
  dingd2ng [options] <channels>...

Options:
  --help                   Show this text.
  --version                Show version.
  --server=<servername>    Connecto to specific server.
  --nick=<nickname>        Use specific nickname.
"""

let args = docopt(doc, version = "dingd2ng v0.2")

var nickname = "dingd2ng"
var server = "chat.freenode.net"
var channels : seq[string] = @[]

if args["--server"]:
  server = $args["--server"]
if args["<channels>"]:
  for chan in @(args["<channels>"]):
    channels.add($chan)
if args["--nick"]:
  nickname = $args["--nick"]

echo("Connecting to IRC on server: ", server, " with nickname ", nickname,
     " in channels: ", channels)

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

var client = newAsyncIrc(server, nick=nickname, realname="dingd2ng",
                 joinChans = channels, callback = onIrcEvent)
asyncCheck client.run()

runForever()