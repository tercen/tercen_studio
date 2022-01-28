# couchdb3

## Migration from couchdb 1.7

```shell

docker exec -it tercen_studio_couchdb3_1 bash

curl -X GET http://admin:admin@127.0.0.1:5984/_all_dbs
# []
curl -X GET http://admin:admin@couchdb:5984/_all_dbs
# ["_replicator","_users","activity","cran","issue","tercen","tercenevents","tercenlocks"]

# create _replicator and _users databases
curl -X PUT http://admin:admin@127.0.0.1:5984/_replicator
curl -X PUT http://admin:admin@127.0.0.1:5984/_users  
 
# start replication
curl -X POST http://admin:admin@127.0.0.1:5984/_replicator  -d '{"source":"http://admin:admin@couchdb:5984/activity", "target":"http://admin:admin@127.0.0.1:5984/activity", "create_target":  true}' -H "Content-Type: application/json"
curl -X POST http://admin:admin@127.0.0.1:5984/_replicator  -d '{"source":"http://admin:admin@couchdb:5984/cran", "target":"http://admin:admin@127.0.0.1:5984/cran", "create_target":  true}' -H "Content-Type: application/json"
curl -X POST http://admin:admin@127.0.0.1:5984/_replicator  -d '{"source":"http://admin:admin@couchdb:5984/issue", "target":"http://admin:admin@127.0.0.1:5984/issue", "create_target":  true}' -H "Content-Type: application/json"
curl -X POST http://admin:admin@127.0.0.1:5984/_replicator  -d '{"source":"http://admin:admin@couchdb:5984/tercen", "target":"http://admin:admin@127.0.0.1:5984/tercen", "create_target":  true }' -H "Content-Type: application/json"

```