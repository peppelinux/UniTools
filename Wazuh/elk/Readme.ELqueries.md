ElasticSearch Wazuh queries
---------------------------

````
apt install jq

curl  "http://172.16.16.253:9200/_cat/indices"

curl  "http://172.16.16.253:9200/wazuh-alerts-3.x-2020.04.06" | jq

curl  "http://172.16.16.253:9200/wazuh-alerts-3.x-2020.04.06/_mapping" | jq

curl  "http://172.16.16.253:9200/wazuh-alerts-3.x-2020.04.06/_search"

curl -X GET "http://172.16.16.253:9200/_search?pretty" \
     -H 'Content-Type: application/json' \
     -d' { "query": { "query_string" : { "query" : "rule.level : 5"} } }'

curl  "http://172.16.16.253:9200/wazuh-alerts-3.x-2020.04.06/_search?q=rule.id:533" 

curl -X GET "http://172.16.16.253:9200/_search?pretty" \
     -H 'Content-Type: application/json' \
     -d' { "query": { "query_string" : { "query" : "(rule.id:533 OR rule.level:10) AND (rule.description:ssh*)"} } }'

curl -X GET "http://172.16.16.253:9200/wazuh-alerts-3.x-2020.04.19/_search?pretty" -H 'Content-Type: application/json' \
        -d' { "query": { "query_string" : { "query" : "rule.groups:web AND rule.level:>5"} } }'


````


Python resources
----------------

- [elasticsearch-py](https://elasticsearch-py.readthedocs.io/en/master/)
- 

ElasticSearch references
------------------------

- [Rest-API](https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html)