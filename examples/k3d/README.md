```shell
# install kubectl
# https://kubernetes.io/docs/tasks/tools/

# v5.2.2
# install k3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.2.2 bash

# volume directory
#sudo mkdir -p /var/lib/rancher/k3s/storage

# create k3d cluster
k3d cluster create --volume /var/lib/rancher/k3s/storage:/var/lib/rancher/k3s/storage

k3d cluster create -p "8080:80@loadbalancer" --volume /var/lib/rancher/k3s/storage:/var/lib/rancher/k3s/storage
k3d cluster list
k3d cluster stop k3s-default
#k3d cluster delete k3s-default
#k3d cluster create my-cluster --api-port 6443 -p 8080:80@loadbalancer --agents 2
# kubectl cluster-info
# kubectl get nodes

kubectl create namespace argocd
# kubectl delete namespace argocd
 
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
#kubectl delete -n argocd -f examples/k3d/argocd/install.yaml
#kubectl apply -n argocd -f examples/k3d/argocd/install.yaml
#kubectl apply -n argocd -f examples/k3d/argocd/argocd-cmd-params-cm.yaml
#kubectl -n argocd get configmap argocd-cmd-params-cm -o yaml

kubectl -n argocd get pods -w
#kubectl -n argocd delete pod argocd-server-bc59fd78c-fqwf6
#kubectl -n argocd logs argocd-server-6bc7b6f869-bvl72 -f

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
# 53LzPBC9drSCS3Ra
 
http://127.0.0.1:8080/argocd

kubectl apply -n argocd -f examples/k3d/argocd/ingress.yaml



sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

kubectl --namespace argocd get pods


kubectl port-forward svc/argocd-server -n argocd 8081:443

kubectl create namespace tercen-studio
kubectl delete namespace tercen-studio

kubectl apply -f examples/k3d/app.yaml
kubectl delete -f examples/k3d/app.yaml
 

argocd login 127.0.0.1:8081
 
argocd app get tercen-studio
argocd app sync tercen-studio

kubectl --namespace tercen-studio get pod
kubectl --namespace tercen-studio get svc

TERCEN_POD=$(kubectl --namespace tercen-studio get pod -l "app=tercen" -o jsonpath='{.items[0].metadata.name}')
kubectl logs --namespace tercen-studio $TERCEN_POD tercen -f
kubectl --namespace tercen-studio port-forward $TERCEN_POD 5600:5400

```

```shell
kubectl apply -f examples/k3d/couchdb/pvc.yaml
# kubectl get pvc,pv
kubectl apply -f examples/k3d/couchdb/couchdb.yaml

kubectl delete -f examples/k3d/couchdb/couchdb.yaml
kubectl delete -f examples/k3d/couchdb/pvc.yaml
# kubectl get pod -w


#COUCH_POD=$(kubectl get pod -l "app=couchdb" -o jsonpath='{.items[0].metadata.name}')
#kubectl port-forward $COUCH_POD 6984:5984

kubectl apply -f examples/k3d/tercen/pvc.yaml

kubectl create configmap tercen-config --from-file=config.yaml=examples/k3d/manifest/tercen-config.yaml -o yaml --dry-run | kubectl apply -f -
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

 ```