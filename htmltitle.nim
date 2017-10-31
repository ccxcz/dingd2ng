# Example program to show the parsexml module
# This program reads an HTML file and writes its title to stdout.
# Errors and whitespace are ignored.

import os, streams, strutils
import httpclient, htmlparser
import xmltree  # To use '$' for XmlNode

proc getHtmlContents(URL : string) : string =
  try:
    var client = newHttpClient()
    return client.getContent(URL)
  except:
    return ""

proc readTitle*(URL : string) : string =
  var contents = getHtmlContents(URL)
  var s = newStringStream(contents)
  var node = parseHtml(s)
  for title in node.findAll("title"):
    return title.innerText

if isMainModule:
  echo(readTitle("https://www.baidu.com"))

#[   while true:
    x.next()
    case x.kind
    of xmlElementStart:
      if cmpIgnoreCase(x.elementName, "title") == 0:
        var title = ""
        x.next()  # skip "<title>"
        while x.kind == xmlCharData:
          title.add(x.charData)
          x.next()
        if x.kind == xmlElementEnd and cmpIgnoreCase(x.elementName, "title") == 0:
          echo("Found title: ", title)
          return title
        else:
          echo(x.errorMsgExpected("/title"))

    of xmlEof: break # end of file reached
    else: discard # ignore other events

  x.close()
  echo "Returning an empty string"
  return "" ]#