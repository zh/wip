import sys, time, openany, feedparser

USER_AGENT = 'my_agent/1.0 +http://localhost'

r = openany.fetch(sys.argv[1], debug=True)
print r['status'], r['reason']

time.sleep(5)

r = openany.fetch(sys.argv[1], last_modified = r['last_modified'], etag = r['etag'], debug = True)
print r['status'], r['reason']
