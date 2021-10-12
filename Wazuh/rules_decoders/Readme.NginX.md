How to evaluate Nginx logs in Wazuh
-----------------------------------

1. Create an agent group called `nginx`
   ````
   /var/ossec/bin/agent_groups -a -g nginx
   ````
2. Edit agent group configuration this way
   ````
   <localfile>
    <location>/var/log/nginx/*.log</location>
    <log_format>apache</log_format>
   </localfile>
   ````
3. Add agents to this group
   ````
   /var/ossec/bin/agent_groups -a -i 014 -g nginx
   ````
4. Control when they are synced
   ````
   /var/ossec/bin/agent_groups -S -i 014
   ````

Test an error 500 or a SQL Injection or whatever... there's alerts!