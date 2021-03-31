Run Tercen using Docker.

# Setup
Install [docker-compose](https://docs.docker.com/compose/install/) for Linux or Windows or Mac.


Clone the following repository
```bash
git clone https://github.com/tercen/tercen_studio.git
cd tercen_studio
```

Activate shared drives (Windows and Mac only)
* right click on the running docker service and select "settings">"shared drives"
* share the folder tercen_studio 

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
docker volume rm tercen_studio_couchdb-data
docker volume rm tercen_studio_tercen-data
docker volume rm tercen_studio_tercen-studio-data
docker volume rm tercen_studio_tercen-studio-renv
```

# Build

```bash
cd docker
docker build -t tercen/tercen_studio:4.0.3-8 docker/r40
docker push tercen/tercen_studio:4.0.3-8

docker build -t tercen/tercen_studio:3.5.3-0 docker/r35
docker push tercen/tercen_studio:3.5.3-0

docker build -t tercen/docker_operator docker/docker_operator
docker build -t tercen/docker_operator .

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

# utils

```shell
sudo chown -R me:mygroup ./config
```
