````
# check nginx have geoip support
nginx -v | grep nginx

# this should be scheduled once per week:
wget -O - http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz | gunzip -c > /opt/GeoIPdb/GeoIP.dat
# otherwise per City: http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz


# then add this to your nginx configuration (default or site)
    # geoip filter
    geoip_country /opt/GeoIPdb/GeoIP.dat;
    map $geoip_country_code $allowed_country {
        #default no;
        IT yes;
    }

    if ($allowed_country = no) {
        return 444;
    }
    # end geoip


# then reload service
/etc/init.d/nginx reload
````
