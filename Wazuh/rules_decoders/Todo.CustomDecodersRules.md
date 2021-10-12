Scrivere Decoders e Rules
-------------------------
https://documentation.wazuh.com/3.12/user-manual/ruleset/custom.html

#### Esempio di Test Regexp su error log nginx

````
esempio = '2020/04/13 17:59:49 [error] 25314#25314: *1466 open() "/opt/tinyurl/tinyurl/static/img/favicon-16x16.png" failed (2: No such file or directory), client: 172.16.16.1, server: url.garrlab.it, request: "GET /static/img/favicon-16x16.png HTTP/1.0", host: "url.garrlab.it", referrer: "https://url.garrlab.it/pht67"'

# test match
/var/ossec/bin/ossec-regex "[error]"

# quindi
echo $esempio | bin/ossec-regex "[error]" 

# esempio più complesso con estrazione di valori

regexp='^(\d+/\d+/\d+ \d+:\d+:\d+) [error] \d+#\d+: \.* "(\.*)" (\.*), client:(\.+), server:(\.+), request:(\.+),'

echo $esempio | /var/ossec/bin/ossec-regex "$regexp"
````

Before making a custom decoder, the first step should always be running the event log through ossec-logtest to know where to start.
https://documentation.wazuh.com/3.12/user-manual/reference/tools/ossec-logtest.html#ossec-logtest

Rules/Decoderss unit tests: https://github.com/wazuh/wazuh/blob/master/contrib/ossec-testing/runtests.py

#### Interactive Unit tests

An SQL injection unit test, which works, which fails
````
# considered rules and decoders
# /var/ossec/ruleset/rules/0245-web_rules.xml 
# /var/ossec/ruleset/decoders/0375-web-accesslog_decoders.xml

# test the apache log as it come from wazuh's web decoder examples
test_apache='10.11.12.13 - - - [27/Mar/2017:13:40:40 -0700] "GET  /modules.php?name=Search&type=stories&query=qualys&category=-1%20&categ=%20and%201=2%20UNION%20SELECT%200,0,aid,pwd,0,0,0,0,0,0%20from%20nuke_authors/* HTTP/1.0" 404 982 "-" "-"'

# test an hard SQL Injection in a nginx example log
# test an hard SQL Injection in a nginx example log
test_nginx='172.16.16.1 - - [10/Apr/2020:15:24:13 +0200] "GET /wordpress/wp-content/plugins/my_custom_plugin/check_user.php?userid%3D-6859+UNION+ALL+SELECT+%28SELECT+CONCAT%280x7171787671%2CIFNULL%28CAST%28ID+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28display_name+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28user_activation_key+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28user_email+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28user_login+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28user_nicename+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28user_pass+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28user_registered+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28user_status+AS+CHAR%29%2C0x20%29%2C0x616474686c76%2CIFNULL%28CAST%28user_url+AS+CHAR%29%2C0x20%29%2C0x71707a7871%29+FROM+wp.wp_users+LIMIT+0%2C1%29%2CNULL%2CNULL-- HTTP/1.0" 200 140936 "https://url.garrlab.it/pht67" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.18363"'

# this work
echo $test_apache | /var/ossec/bin//ossec-logtest -q -c /var/ossec/etc/ossec.conf -D /var/ossec/ -U 31103:0:web-accesslog -v

# this work
echo $test_nginx | /var/ossec/bin//ossec-logtest -q -c /var/ossec/etc/ossec.conf -D /var/ossec/ -U 31103:0:web-accesslog_decoders -v
````

in `/var/ossec/ruleset/rules/0245-web_rules.xml` we found
````
  <rule id="31103" level="6">
    <if_sid>31100,31108</if_sid>
    <url>=select%20|select+|insert%20|%20from%20|%20where%20|union%20|</url>
    <url>union+|where+|null,null|xp_cmdshell</url>
    <description>SQL injection attempt.</description>
    <group>attack,sql_injection,pci_dss_6.5,pci_dss_11.4,pci_dss_6.5.1,gdpr_IV_35.7.d,nist_800_53_SA.11,nist_800_53_SI.4,</group>
  </rule>

````
