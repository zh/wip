import sys, openany, feedparser

USER_AGENT = 'my_agent/1.0 +http://localhost'

r = openany.fetch(sys.argv[1], debug=True)
if r['status'] != 200:
  print r['status'], r['reason']
else:
  feed = feedparser.parse(sys.argv[1])
  print feed['feed']['title']
  for i in range(0, len(feed['entries'])):
    print feed['entries'][i]['title']
