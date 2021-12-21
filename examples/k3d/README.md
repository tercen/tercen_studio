```shell
# v5.2.2
# install k3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.2.2 bash

# volume directory
sudo mkdir -p /var/lib/rancher/k3s/storage
sudo chown  $USER:$USER /var/lib/rancher/k3s/storage

# create k3d cluster
k3d cluster create -p "8081:80@loadbalancer" --volume /var/lib/rancher/k3s/storage:/var/lib/rancher/k3s/storage
#k3d cluster create my-cluster --api-port 6443 -p 8080:80@loadbalancer --agents 2
# kubectl cluster-info
# kubectl get nodes

kubectl apply -f examples/k3d/couchdb/pvc.yaml
# kubectl get pvc,pv
kubectl apply -f examples/k3d/couchdb/couchdb.yaml

kubectl delete -f examples/k3d/couchdb/couchdb.yaml
kubectl delete -f examples/k3d/couchdb/pvc.yaml
# kubectl get pod -w


#COUCH_POD=$(kubectl get pod -l "app=couchdb" -o jsonpath='{.items[0].metadata.name}')
#kubectl port-forward $COUCH_POD 6984:5984

kubectl apply -f examples/k3d/tercen/pvc.yaml

kubectl create configmap tercen-config --from-file=config.yaml=examples/k3d/tercen/tercen-config.yaml -o yaml --dry-run | kubectl apply -f -
kubectl apply -f examples/k3d/tercen/tercen.yaml
kubectl apply -f examples/k3d/tercen/ingress.yaml

kubectl delete -f examples/k3d/tercen/ingress.yaml
kubectl delete -f examples/k3d/tercen/tercen.yaml
kubectl delete -f examples/k3d/tercen/pvc.yaml
kubectl delete configmap tercen-config
# kubectl get pod -w

TERCEN_POD=$(kubectl get pod -l "app=tercen" -o jsonpath='{.items[0].metadata.name}')
kubectl logs $TERCEN_POD tercen -f
kubectl port-forward $TERCEN_POD 54000:5400
kubectl exec -it $TERCEN_POD tercen -- bash

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

kubectl --namespace argocd get pods
```