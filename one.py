import urllib, urllib2, re

for i in range(731, 774):
    url = 'http://wufazhuce.com/one/vol.%d' % i

    source = urllib2.urlopen(url, timeout=30).read()

    res = re.findall(r'<div class="one-cita">(.*?)</div>', source, re.S)
    if(len(res) > 0):
        print res[0].strip()