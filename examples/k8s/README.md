```shell
minikube start --cpus=12 --memory 40000 --gpus all --addons=ingress,dashboard,metrics-server
```
 
```shell
kubectl apply -f sci_api_service/bin/k8s/serviceaccount.yaml

kubectl apply -f sci_api_service/bin/k8s/couchdb/couchdb-pvc.yaml
kubectl apply -f sci_api_service/bin/k8s/couchdb/couchdb.yaml
# kubectl delete -f sci_api_service/bin/k8s/couchdb/couchdb.yaml


kubectl create configmap tercen-config --from-file=config.yaml=examples/k8s/tercen/config/tercen-config.yaml -o yaml --dry-run=client | kubectl apply -f -
# kubectl delete configmap tercen-config
kubectl describe configmaps tercen-config

kubectl apply -f examples/k8s/tercen/tercen-pvc.yaml
kubectl apply -f examples/k8s/tercen/tercen-service.yaml
kubectl apply -f examples/k8s/tercen/tercen.yaml
#kubectl delete -f examples/k8s/tercen/tercen.yaml

kubectl rollout restart deployment tercen-deployment

kubectl apply -f examples/k8s/ingress.yaml
kubectl get ingress
kubectl get svc
```
  

```shell
kubectl get pods -w
kubectl get svc

COUCH_POD=$(kubectl get pod -l "app=couchdb" -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $COUCH_POD bash 
kubectl logs --tail=200 -f $COUCH_POD
kubectl describe pod $COUCH_POD
kubectl port-forward $COUCH_POD 6984:5984
```


```shell
TERCEN_POD=$(kubectl get pod -l "app=tercen" -o jsonpath='{.items[0].metadata.name}')
kubectl logs $TERCEN_POD tercen-pod  --previous
kubectl logs --tail=200 -f $TERCEN_POD tercen-pod  

kubectl port-forward $TERCEN_POD 5403:5400

```


# GKE

```shell

```