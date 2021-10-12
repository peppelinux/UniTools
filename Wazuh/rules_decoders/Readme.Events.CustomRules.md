Events and CustomRules
----------------------

In questo documento collezioniamo e documentiamo gli eventi che non vengono rielvati da Wazuh ma che richiederebbero una regola Custom.


Web Code Injection
````
# PHP Code injection, dovrebbe essere pari a level 6.
log: '10.101.0.209 - - [06/Apr/2020:17:00:07 +0200] "GET /?a=fetch&content=<php>die(@md5(HelloThinkCMF))</php> HTTP/1.1" 301 178 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"'

# js code injection
log: '10.101.0.209 - - [06/Apr/2020:17:01:36 +0200] "GET /index.php?s=/Index/\x5Cthink\x5Capp/invokefunction&function=call_user_func_array&vars[0]=md5&vars[1][]=HelloThinkPHP HTTP/1.1" 301 178 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"'
````

