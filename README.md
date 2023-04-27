Run Tercen using Docker.

# Setup
Install [docker-compose](https://docs.docker.com/compose/install/) for Linux or Windows or Mac.


Clone the following repository
```bash
git clone https://github.com/tercen/tercen_studio.git
cd tercen_studio
```

Create tercen network

```shell
docker network create tercen
```

Then start tercen ...

```bash
docker-compose up -d
```

Go to [http://127.0.0.1:5402](http://127.0.0.1:5402) to access Tercen.

Username : admin

Password : admin

Go to [http://127.0.0.1:8787/](http://127.0.0.1:8787/) to access RStudio.
 
Username : rstudio

Password : tercen


# Update

```bash
# stop tercen_studio
docker-compose down        
# get tercen_studio latest version           
git pull
docker-compose pull
# start tercen_studio
docker-compose up -d

# check allocated worker threads and memory (see config.yaml for more settings)
docker-compose logs tercen | grep tercen.worker.isolates
docker-compose logs tercen | grep tercen.worker.memory
``` 
 
# Uninstall

```bash
docker-compose down
# check tercen docker volumes names
docker volume ls
# delete tercen docker volumes
docker volume rm tercen_studio_couchdb3-data
docker volume rm tercen_studio_tercen-data
docker volume rm tercen_studio_tercen-studio-data
docker volume rm tercen_studio_tercen-studio-renv
```

# Build

```bash
git tag tercen-studio-r35_3.5.3-1
git push --tags

git tag tercen-studio-r40_4.0.4-5
git push --tags

#docker build -t tercen/tercen-studio-flowsuite docker/tercen-studio-flowsuite
git tag tercen-studio-flowsuite_3.15-6
git push --tags

docker run -it --rm -v /home/alex/dev/tercen/tercen_studio/:/root/mydevfolder tercen/docker_operator bash
```

# Logs

```bash
docker-compose logs tercen
```

Default log level is config(400) , log level configuration can be set in the file ./config/tercen/config.yaml.

```yaml
# tercen.log.level: '400'
tercen.log.level: '0'
```

Then restart tercen

```bash
# stop tercen_studio
docker-compose down        
# start tercen_studio
docker-compose up -d
```
