

```shell

internal: true
docker network create --driver bridge isolated_network

docker run -it --rm --network isolated_network --name my_container --entrypoint bash tercen/tercen:stage


docker rm my_container 
docker network rm isolated_network
```

```shell
docker exec -it http_proxy-tercen-1 bash
docker run -it --entrypoint=bash -v /etc/ssl/certs:/etc/ssl/certs tercen/runtime-r40:4.0.4-6

export http_proxy=http://172.43.0.142:3128
export https_proxy=http://172.43.0.142:3128

wget https://cran.tercen.com/api/v1/rlib/tercen/src/contrib/PACKAGES

docker run -it --rm --dns 8.8.8.8 --entrypoint=bash -v /etc/ssl/certs:/etc/ssl/certs tercen/runtime-r40:4.0.4-6
```