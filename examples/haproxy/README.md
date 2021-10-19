# haproxy

see config file

examples/haproxy/config/haproxy/haproxy.cfg

# tercen settings

see config file

examples/haproxy/config/tercen/config.yaml

Change the following settings
```yaml
# use to pad password before hashing
tercen.secret: "f1afc1b3-0782-41da-9cd0-5a094f940074"
```

Tercen uses github to store operators code. Github set a limit on the number of unauthenticated request.

```yaml
# To bypass github unauthenticated request limit set a github token.
tercen.github.token: xxxxxxx
```

# tercen

```shell
cd examples/haproxy
docker-compose pull
docker-compose up -d
```