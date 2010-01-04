#!/usr/bin/env python
# Corey Goldberg - September 2009


import httplib
import sys
import time



if len(sys.argv) != 2:
    print 'usage:\nhttp_profiler.py \n(do not include http://)'
    sys.exit(1)

# get host and path names from url
location = sys.argv[1]
if '/' in location:
    parts = location.split('/')
    host = parts[0]
    path = '/' + '/'.join(parts[1:])
else:
    host = location
    path = '/'

# select most accurate timer based on platform
if sys.platform.startswith('win'):
    default_timer = time.clock
else:
    default_timer = time.time

# profiled http request
conn = httplib.HTTPConnection(host)
start = default_timer()  
conn.request('GET', path)
request_time = default_timer()
resp = conn.getresponse()
response_time = default_timer()
size = len(resp.read())
conn.close()     
transfer_time = default_timer()

# output
print '%.5f request sent' % (request_time - start)
print '%.5f response received' % (response_time - start)
print '%.5f content transferred (%i bytes)' % ((transfer_time - start), size)

