# Introduction

This document describes the installation and usage of [tercen](https://tercen.com/) running on 2 nodes

Requirements: k8s cluster with LoadBalancer service running

2 types of storage are necessary:
- block storage
- shared file system

Any shared file system can be used (CephFS,Amazon EFS,NFS,GlusterFS, etc), in this document we use Rook NFS.

Tercen is composed of a number of components.
- couchdb
- tercen main service
- tercen worker service
 
\
\

![tercen-cluster](../../doc/tercen-cluster.png)

\
\

# Install Rook NFS

https://rook.io/docs/nfs/v1.7/quickstart.html

```shell
# 
git clone --single-branch --branch v1.7.3 https://github.com/rook/nfs.git

cd nfs/cluster/examples/kubernetes/nfs

kubectl create -f crds.yaml
kubectl create -f operator.yaml
kubectl create -f rbac.yaml


```

## Storage class for EBS

Edit nfs-xfs.yaml and set the following :

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard-xfs
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  iopsPerGB: "10"
  fsType: xfs
mountOptions:
  - prjquota
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

Create the nfs server.

```shell
kubectl create -f nfs-xfs.yaml
```

Create rook nfs storage class.
```shell
kubectl create -f sc.yaml
```

# Node label

```shell
kubectl get nodes

kubectl label nodes ip-192-168-6-126.eu-central-1.compute.internal app=tercen
kubectl label nodes ip-192-168-61-38.eu-central-1.compute.internal app=tercen-worker
```

# Install tercen

## Storage

```shell
kubectl apply -f examples/k8s/storage/rook/pvc.yaml
kubectl get pvc
```

## Couchdb

```shell
kubectl apply -f examples/k8s/couchdb.yaml
```

## External Tercen service

External Tercen service is a service that is exposed to the internet, here we are using a kubernetes load balancer.

```shell
kubectl apply -f examples/k8s/tercen-service-lb.yaml

# get tercen service external ip
kubectl get svc

```

## Tercen config

Set tercen external ip in config files and the following properties:

- tercen.admin.password
- tercen.secret
- tercen.auth.cookie.domain
- tercen.test.password
- tercen.public.uri
- tercen.public.client.uri

```shell
kubectl create configmap tercen-config --from-file=config.yaml=examples/k8s/tercen-config.txt -o yaml --dry-run=client | kubectl apply -f -
kubectl create configmap tercen-worker-config --from-file=config.yaml=examples/k8s/tercen-worker-config.txt -o yaml --dry-run=client | kubectl apply -f -
```

## SAML config

Store the Identity Provider certificate in a configmap.

```shell
kubectl create configmap tercen-saml-cert \
  --from-file=cert.pem=examples/k8s/sso/saml/cert.pem -o yaml --dry-run=client | kubectl apply -f -
```

To use SAML authentication the following properties need to be configured in tercen config file.

```yaml
tercen.auth.method: 'saml'
tercen.saml.request.issuer: https://my.tercen.com/_service/sso/auth/saml
tercen.saml.idp.issuer: https://sts.windows.net/5b5c94c6-14cf-42da-85bc-4e08722b253b/
tercen.saml.audience: https://my.tercen.com/_service/sso/auth/saml
tercen.saml.binding.url: https://login.microsoftonline.com/5b5c94c6-14cf-42da-85bc-4e08722b253b/saml2
tercen.saml.certificate.file: /etc/tercen/saml/cert.pem
```
 
In tercen.yaml file manifest uncomment the following lines :

```yaml
      volumes:
        - name: tercen-saml-cert
          configMap:
            name: tercen-saml-cert
```

and 

```yaml
          volumeMounts:
            - name: tercen-saml-cert
              mountPath: /etc/tercen/saml
```

## Tercen services

```shell
kubectl apply -f examples/k8s/tercen.yaml
kubectl apply -f examples/k8s/tercen-worker.yaml

TERCEN_POD=$(kubectl get pod -l "app=tercen" -o jsonpath='{.items[0].metadata.name}')

kubectl logs $TERCEN_POD tercen

# check if tercen is running using k8s port forward
kubectl port-forward $TERCEN_POD 6400:5400
# http://localhost:6400/
```

http://tercen-external-ip
