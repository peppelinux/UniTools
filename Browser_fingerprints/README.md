Test your browser
-----------------
- https://browserleaks.com/
- https://panopticlick.eff.org
- https://browserprint.info/
- http://useragentstring.com/

Additional resources
--------------------
https://pixelprivacy.com/resources/browser-fingerprinting/
https://amiunique.org/tools
https://medium.com/@ravielakshmanan/web-browser-uniqueness-and-fingerprinting-7eac3c381805
https://www.fastly.com/blog/understanding-vary-header-browser

Canvas focused
-------------
https://multilogin.com/how-canvas-fingerprint-blockers-make-you-easily-trackable/


Made Linux act as Windows
-------------------------
some notes here.
````
echo 128 > /proc/sys/net/ipv4/ip_default_ttl
echo 0 > /proc/sys/net/ipv4/tcp_window_scaling
echo 0 > /proc/sys/net/ipv4/tcp_timestamps
````

Countermeasures
---------------

Canvas:
- Canvas defender addon with 1 minut noise autogeneration (see coniguration)

Hack tools
----------
Python script that generates user_agents profiles. Good code to push random user agents profiles through privoxy.
- https://github.com/lorien/user_agent
- https://github.com/hellysmile/fake-useragent
- User agent list: http://www.useragentstring.com/pages/useragentstring.php

Python example
````
import requests
from fake_useragent import UserAgent

url = 'http://www.ichangtou.com/#company:data_000008.html'
ua = UserAgent()
ua.chrome
#u'Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36'
ua.random
#u'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 Safari/537.36'
headers = {'User-Agent': str(ua.random)}

response = requests.get(url, headers=headers)
print(response.content)
````

