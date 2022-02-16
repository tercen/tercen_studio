# Setup

Create docker network

```shell
docker network create tercen
```

Start tercen

```shell
cd examples/externam_storage
docker-compose pull
docker-compose up -d
```

# Operator external storage

2 folders are mounted into docker operators containers :

```shell
/var/lib/tercen/share/read
/var/lib/tercen/share/write
```

On the host those folders are located here 

```shell
/var/lib/tercen/external/read
/var/lib/tercen/external/write
```

