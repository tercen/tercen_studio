# tercen studio

Inside a terminal run the following

```bash
docker container run -d --name tercen_studio \
 -p 8787:8787 \
 -e PASSWORD=tercen \
 -v ${PWD}/rstudio/home:/home/rstudio/home \
 -w /home/rstudio \
 tercen/tercen_studio:0.7.1.3
```

Open chrome [http://localhost:8787/](http://localhost:8787/)

Username : rstudio

Password : tercen
 
# Remove 

```bash
docker rm -f tercen_studio
```

# Build

```bash
docker build -t tercen/tercen_studio:0.7.1.3 .
docker push tercen/tercen_studio:0.7.1.3
```