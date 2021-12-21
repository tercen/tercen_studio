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

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

kubectl --namespace argocd get pods

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
# QstMip1O84VoEdS1
kubectl port-forward svc/argocd-server -n argocd 8080:443

kubectl create namespace tercen-studio
kubectl delete namespace tercen-studio

kubectl apply -f examples/k3d/app.yaml
kubectl delete -f examples/k3d/app.yaml
 

argocd login 127.0.0.1:8080

argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default`

argocd app get tercen-studio
argocd app sync tercen-studio

kubectl --namespace tercen-studio get pods
kubectl --namespace tercen-studio describe pod tercen-deployment-65964f78ff-k8hvb
```