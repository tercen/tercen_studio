# tercen studio

Inside a terminal run the following

```bash
docker container run -d --name tercen_studio \
 -p 8787:8787 \
 -e PASSWORD=tercen \
 -v ${PWD}/rstudio/home:/home/rstudio/home \
 -w /home/rstudio \
 tercen/tercen_studio:0.7.1
```

Open chrome [http://localhost:8787/](http://localhost:8787/)

Username : rstudio

Password : tercen

# Build

```bash

docker build -t tercen/tercen_studio:0.7.1 .
docker push tercen/tercen_studio:0.7.1


```