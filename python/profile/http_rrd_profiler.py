#!/usr/bin/env python
# Corey Goldberg - Dec 2009


import httplib
import sys
import time
import rrd


GRAPH_MINS = 15

if len(sys.argv) != 3:
    print 'usage:\nhttp_rrd_profiler.py <host> <interval>\n'
    sys.exit(1)
host = sys.argv[1]
interval = int(sys.argv[2])


# choose timer to use
if sys.platform.startswith('win'):
    default_timer = time.clock
else:
    default_timer = time.time
    
    
    
def main():
    my_rrd = rrd.RRD('http_latency.rrd')
    my_rrd.create_rrd(interval)
    while True:
        start = default_timer()
        try:
            times = timed_req(host)
        except Exception, e:
            print 'failed: ' % e
        size, request_time, response_time, transfer_time = times
        print '----------------'
        print '%.0f request sent' % request_time
        print '%.0f response received' % response_time
        print '%.0f content transferred (%i bytes)' % (transfer_time, size)
        time_set = (request_time, response_time, transfer_time)
        my_rrd.update(time_set)
        my_rrd.graph(GRAPH_MINS)
        elapsed = default_timer() - start
        time.sleep(interval - elapsed)
        


def timed_req(host):
    conn = httplib.HTTPConnection(host)
    conn.set_debuglevel(0)
    start_timer = default_timer()
    conn.request('GET', '/')     
    request_timer = default_timer()
    resp = conn.getresponse()
    response_timer = default_timer()
    content = resp.read()
    conn.close()
    transfer_timer = default_timer()
    size = len(content)
    
    # convert to offset millisecs
    request_time = (request_timer - start_timer) * 1000
    response_time = (response_timer - start_timer) * 1000
    transfer_time = (transfer_timer - start_timer) * 1000
            
    return (
        size,
        request_time, 
        response_time, 
        transfer_time, 
        )



if __name__ == '__main__':
    main()