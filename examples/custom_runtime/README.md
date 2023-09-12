# Build and deploy tercen custom runtime

```shell
IMAGE=myorg/tercen-runtime-r40:4.0.4-6
docker build -t ${IMAGE} .
docker push ${IMAGE}
```

In tercen config file add the following
```yaml
Runtimes:
- name: R-3.5
  image: tercen/runtime-r35:3.5.3-7
- name: R-4.0
  image: myorg/tercen-runtime-r40:4.0.4-6
```