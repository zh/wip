import gzip, socket
import httplib, cookielib, urlparse
import urllib2

from StringIO import StringIO

USER_AGENT = 'OpenAnything/1.0 +http://diveintopython.org/'

# timeout in seconds
timeout = 5
socket.setdefaulttimeout(timeout)

class DefaultErrorHandler(urllib2.HTTPDefaultErrorHandler):
  def http_error_default(self, req, fp, code, msg, headers):
    result = urllib2.HTTPError(req.get_full_url(), code, msg, headers, fp)       
    result.code = code
    return result

class NotModifiedHandler(urllib2.BaseHandler):
  def http_error_304(self, req, fp, code, msg, headers):
    result = urllib2.addinfourl(fp, headers, req.get_full_url())
    result.code = code
    result.msg = "Not Modified"
    return result

class SmartRedirectHandler(urllib2.HTTPRedirectHandler):
  def http_error_301(self, req, fp, code, msg, headers):
    result = urllib2.HTTPRedirectHandler.http_error_301(self, req, fp, code, msg, headers)
    result.code = code
    return result                                       

  def http_error_302(self, req, fp, code, msg, headers):
     result = urllib2.HTTPRedirectHandler.http_error_302(self, req, fp, code, msg, headers)              
     result.code = code
     return result 

## Create an OpenerDirector with support for Basic HTTP Authentication...
# auth_handler = urllib2.HTTPBasicAuthHandler()
# auth_handler.add_password(realm='PDQ Application',
#                           uri='https://mahler:8092/site-updates.py',
#                           user='klem',
#                           passwd='kadidd!ehopper')
# opener = urllib2.build_opener(auth_handler)

def build_opener(debug=False):
    # Create a HTTP and HTTPS handler with the appropriate debug
    # level.  We intentionally create a new one because the
    # OpenerDirector class in urllib2 is smart enough to replace
    # its internal versions with ours if we pass them into the
    # urllib2.build_opener method.  This is much easier than trying
    # to introspect into the OpenerDirector to find the existing
    # handlers.
    http_handler = urllib2.HTTPHandler(debuglevel=debug)
    https_handler = urllib2.HTTPSHandler(debuglevel=debug)

    # We want to process cookies, but only in memory so just use
    # a basic memory-only cookie jar instance
    cookie_jar = cookielib.CookieJar()
    cookie_handler = urllib2.HTTPCookieProcessor(cookie_jar)

    # errors
    error_handler = DefaultErrorHandler()
    redir_handler = SmartRedirectHandler()
    notmod_handler = NotModifiedHandler()

    handlers = [ http_handler, 
                 https_handler, 
                 cookie_handler, 
                 error_handler,
                 notmod_handler,
                 redir_handler]
    opener = urllib2.build_opener(*handlers)

    # Save the cookie jar with the opener just in case it's needed
    # later on
    opener.cookie_jar = cookie_jar

    return opener


def openAnything(source, etag=None, last_modified=None, agent=USER_AGENT, debug=False):
  # non-HTTP code omitted for brevity
  if urlparse.urlparse(source)[0] == 'http':
    req = urllib2.Request(source)
    req.add_header('User-Agent', agent)
    req.add_header('Accept-encoding', 'gzip')
    if etag:
      req.add_header('If-None-Match', etag)
    if last_modified:
      req.add_header('If-Modified-Since', last_modified)
    opener = build_opener(debug)
    return opener.open(req)


def fetch(source, etag=None, last_modified=None, agent=USER_AGENT, debug=False):
  '''Fetch data and metadata from a URL, file, stream, or string'''
  result = {}
  f = openAnything(source, etag, last_modified, agent, debug)
  if hasattr(f, 'code') and f.code == 304:
    result['data'] = "304 Not Modified"
  else:  
    result['data'] = f.read()
  if hasattr(f, 'headers'):
    # save ETag, if the server sent one
    result['etag'] = f.headers.get('ETag')
    # save Last-Modified header, if the server sent one
    result['last_modified'] = f.headers.get('Last-Modified')
    if f.headers.get('content-encoding', '') == 'gzip':
      # data came back gzip-compressed, decompress it
      result['data'] = gzip.GzipFile(fileobj=StringIO(result['data'])).read()
  result['status'] = f.code
  result['reason'] = f.msg
  f.close
  return result
