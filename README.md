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
```

# Build

```bash
cd docker
docker build -t tercen/tercen_studio:0.9.2.2 .
docker history --no-trunc tercen_studio:0.9.2.2 
docker push tercen/tercen_studio:0.9.2.2
```