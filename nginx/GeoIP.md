````
# check nginx have geoip support
nginx -v | grep geoip

# this should be scheduled once per week:
wget -O - http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz | gunzip -c > /opt/GeoIPdb/GeoIP.dat
# otherwise per City: http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz


cat << EOF > /etc/nginx/conf.d/geoip.conf
    # geoip filter
    geoip_country /opt/GeoIPdb/GeoIP.dat;
    map \$geoip_country_code \$allowed_country {
        default no;
        IT yes;
    }
EOF

# then add this to your site configuration
    if ($allowed_country = no) {
        return 444;
    }
    # end geoip


# then reload service
/etc/init.d/nginx reload
````
