# This module defines window.ponyExpress.
#
# It is injected into pages as a content script (to identify whether
# we want to replace them) as well as in the replaced pages (to extract
# information out of the URL).

isPiperMail = (url) ->
  # Parse URL using the DOM, yikes!
  a = document.createElement 'a'
  a.href = url

  if a.protocol != 'file:'
    matches = a.pathname.match ///
      /pipermail/
      ([^/]+)/
      (.*)
    ///
  else
    # Special-case tests for this extension itself.
    matches = a.pathname.match ///
      /pony-express/testdata/
      ([^/]+)/
      (.*)
    ///

  if matches
    [_, list, rest] = matches
  else if a.host.match /^lists./
    # Get more aggressive on lists.foobar.org URLs.
    matches = a.pathname.match ///
      /archives/
      ([^/]+)/
      (.*)
    ///
    return null unless matches
    [_, list, rest] = matches
  else
    return null

  if a.protocol == 'file:' and a.pathname.match /\/$/
    # Cross-origin checks from file:/// URLs showing directories
    # are screwed in Chrome.
    return null

  breakdown =
    url: url
    base: url.substr(0, url.length - rest.length)
    list: list

  parts = rest.split '/'
  if parts.length == 2
    [breakdown.month, rest] = parts
    switch rest
      when '', 'thread.html'  # ignore
      else breakdown.thread = rest
  else if parts.length == 1
    if parts[0] != 'index.html'
      breakdown.month = parts[0]
  else
    return null

  return breakdown

this.ponyExpress =
  isPiperMail: isPiperMail
