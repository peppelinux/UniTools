Elastic Search snapshot and restore
-----------------------------------
https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html


Create the path
````
mkdir /var/backups/elasticsearch/
chown elasticsearch:elasticsearch /var/backups/elasticsearch/
````

Edit `/etc/elasticsearch/elasticsearch.yml` and configure a snapshot repository.
````
#
# Path to backup repositories:
#
path.repo: /var/backups/elasticsearch 
````

Restart elastic search
````
service elasticsearch restart
````

Register the repository in EL
````
curl -X PUT "172.16.16.253:9200/_snapshot/elastic_backups?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/backups/elasticsearch/"
  }
}
'
````

Get all the data repositories
````
curl -X GET "172.16.16.253:9200/_snapshot?pretty"
````

Get a snapshot of all indices ("indices": "index_1,index_2" or "_all")
````
curl -X PUT "172.16.16.253:9200/_snapshot/elastic_backups/snapshot_19042020?wait_for_completion=true&pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "_all",
  "ignore_unavailable": true,
  "include_global_state": false,
  "metadata": {
    "taken_by": "gdemarco",
    "taken_because": "daily snapshot"
  }
}
'
````

Get information about a snapshot
````
curl -X GET "172.16.16.253:9200/_snapshot/elastic_backups/snapshot_19042020?pretty"
````

Restore
-------

https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html
