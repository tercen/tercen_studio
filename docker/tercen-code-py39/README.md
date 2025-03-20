```shell

IMAGE=tercen/tercen-code-py39:3.9.17-3
docker build -t ${IMAGE} .


git tag tercen-code-py39_3.9.17-3
#docker push ${IMAGE}
```