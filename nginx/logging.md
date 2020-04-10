Nginx debug and logs
--------------------

in `/etc/nginx/nginx.conf`, in http section, create this definition
````
        log_format addHeaderlog '$remote_addr - $remote_user [$time_local] '
                                '"$request" $status $body_bytes_sent '
                                '$http_x_real_ip '
                                '"$http_referer" "$http_user_agent" "$http_x_forwarded_for" "$request_body" '
                                '"$http_Authorization" "$http_x_duid" "$http_x_ver" "$upstream_http_x_rqid"';

````

**Please** omit `$request_body` in production for privacy and security policies.

Then add this kind of log in each sites configuration
````
access_log /var/log/nginx/access.headers.log addHeaderlog;
````
