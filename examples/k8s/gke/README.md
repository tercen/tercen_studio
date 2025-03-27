# Deploy tercen on GKE

- Create cluster
- Deploy Tercen
- Configure TLS using Google-managed SSL certificates
- Configure Authentication using Google OAuth 2.0 Client IDs

# Install gcloud

https://cloud.google.com/sdk/docs/install#deb

```shell

gcloud init
gcloud auth login
```

# Install gke-gcloud-auth-plugin

https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_plugin

```shell

sudo apt install google-cloud-cli-gke-gcloud-auth-plugin

```

# Create cluster

https://cloud.google.com/kubernetes-engine/docs/deploy-app-cluster

```shell
CLUSTER_NAME=tc-test-cluster
ZONE=europe-west1-b
 europe-west1
 
gcloud container clusters create $CLUSTER_NAME \
    --num-nodes=1 \
    --zone=$ZONE 
     
# get credentials for kubectl
gcloud container clusters get-credentials $CLUSTER_NAME \
    --zone=$ZONE 
    
kubectl get nodes
```

# Create worker node pool

```shell
# https://cloud.google.com/kubernetes-engine/docs/how-to/node-pools

gcloud container node-pools list --cluster $CLUSTER_NAME \
    --zone=$ZONE 
    
#gcloud container node-pools describe default-pool \
#    --cluster $CLUSTER_NAME \
#    --zone=$ZONE 
      
gcloud container node-pools create worker-pool \
    --cluster $CLUSTER_NAME \
    --num-nodes=1 \
    --machine-type e2-highmem-16 \
    --node-labels app=worker \
    --zone=$ZONE 
    
#    --disk-type=pd-ssd \
#    --disk-size=100GB \
  

#gcloud container node-pools delete worker-pool \
#    --cluster $CLUSTER_NAME \
#    --zone=$ZONE 
    
#gcloud container node-pools update worker-pool \
#    --cluster $CLUSTER_NAME \
#    --node-labels app=worker \
#    --zone=$ZONE 
```

# GPU pool

```shell
gcloud compute accelerator-types list | grep $ZONE

#We are testing the deployment of our product on a Google Kubernetes Engine (GKE) 
#cluster in the europe-west1 region for a client who will perform a data analysis workflow 
#primarily using TensorFlow. This deployment requires at least 4 NVIDIA T4 GPUs initially, 
#with autoscaling capabilities to dynamically adjust GPU resources based on workload demand 
#during testing. Our current GPU quota of 0 prevents us from provisioning GPU-enabled 
#node pools with autoscaling in GKE, hindering our ability to validate performance and 
#scalability for the client's production environment. Increasing our quota to 4 NVIDIA T4 GPUs 
#will enable us to implement and test an autoscaling setup,
# ensuring the solution efficiently handles variable data analysis loads before final delivery to the client.
 

gcloud container node-pools create gpu-pool \
  --cluster=$CLUSTER_NAME \
  --zone=$ZONE \
  --machine-type=n1-standard-4 \
  --accelerator=type=nvidia-tesla-t4,count=1 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=1
  
gcloud container operations describe operation-1742828009680-2add8fff-4a0b-4ae5-b37b-ad83f911baf9 \
   --zone=$ZONE
```

# Add app=couch label to a specific node

```shell
kubectl get node -o wide
kubectl get nodes --show-labels
kubectl label --list nodes gke-tc-test-cluster-default-pool-55e4b665-7szb
kubectl label nodes gke-tc-test-cluster-default-pool-55e4b665-7szb app=couchdb
```
 
# Apply tercen resources

```shell
kubectl get node -o wide
kubectl get pod -w
kubectl get pod -o wide
kubectl get pvc -w
kubectl get sa

kubectl apply -f sci_api_service/bin/k8s/serviceaccount.yaml
kubectl apply -f sci_api_service/bin/k8s/gke/couchdb/couchdb-pvc.yaml
#kubectl delete -f sci_api_service/bin/k8s/gke/couchdb/couchdb-pvc.yaml
kubectl apply -f sci_api_service/bin/k8s/couchdb/couchdb.yaml
#kubectl delete -f sci_api_service/bin/k8s/couchdb/couchdb.yaml

kubectl create configmap tercen-config --from-file=config.yaml=sci_api_service/bin/k8s/tercen/config/tercen-config.yaml -o yaml --dry-run=client | kubectl apply -f -
# kubectl delete configmap tercen-config
kubectl describe configmaps tercen-config

kubectl apply -f sci_api_service/bin/k8s/gke/tercen/tercen-pvc.yaml
kubectl apply -f sci_api_service/bin/k8s/tercen/tercen-service.yaml
kubectl apply -f sci_api_service/bin/k8s/tercen/tercen.yaml
#kubectl delete -f sci_api_service/bin/k8s/tercen/tercen.yaml

kubectl rollout restart deployment tercen-deployment

TERCEN_POD=$(kubectl get pod -l "app=tercen" -o jsonpath='{.items[0].metadata.name}')
kubectl logs $TERCEN_POD tercen-pod  --previous
kubectl logs --tail=200 -f $TERCEN_POD tercen-pod  

kubectl port-forward $TERCEN_POD 5403:5400


 

kubectl apply -f backend-config.yaml
kubectl apply -f tercen/tercen.yaml
# kubectl delete -f tercen/tercen.yaml
# kubectl get service tercen-service
# kubectl get pod -o wide -w
# kubectl port-forward tercen-deployment-b8f55895-57ns6 5600:5400
# http://127.0.0.1:5600
# kubectl logs tercen-deployment-b8f55895-57ns6

kubectl apply -f ingress.yaml

#kubectl get ingress tercen-ingress
#kubectl describe ingress tercen-ingress

# ingress IP must be set in tercen config and updated
kubectl rollout restart deployment tercen-deployment

# gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE 
   
```

# Ingress : TLS endpoint

https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs


# Google OAuth 2.0 Client IDs

https://console.cloud.google.com/apis/credentials

Client ID for Web application

Authorised JavaScript origins
- https://mydomain.com
  https://kumo-dev.thinkcyte.cloud

Authorised redirect URIs
- https://mydomain.com/?auth.provider=google
- https://kumo-dev.thinkcyte.cloud/?auth.provider=google


See config file ...

```shell
#tercen.auth.client.id.google: 'xxxx.apps.googleusercontent.com'
#tercen.auth.client.secret.google: 'xxxxx'
```

# Brand

```shell
kubectl create configmap brand-config --from-file=brand.zip=tercen/config/brand.zip -o yaml --dry-run=client | kubectl apply -f -

```

# utils

```shell

TERCEN_POD=$(kubectl get pod -l "app=tercen" -o jsonpath='{.items[0].metadata.name}')

kubectl logs --tail=200 -f $TERCEN_POD tercen  
kubectl exec -it $TERCEN_POD --container tercen -- bash

# how much storage is left on device in /var/lib/tercen/data
kubectl exec $TERCEN_POD -- df -ah
```

# Delete cluster and Cleanup 

```shell
# node pool are automatically deleted
gcloud container clusters delete $CLUSTER_NAME \
  --zone=$ZONE \
  --quiet
  
gcloud compute disks list --filter="name:$CLUSTER_NAME"

gcloud compute disks delete gke-my-cluster-disk-name \
  --zone=$ZONE \
  --quiet
  
gcloud compute disks list --filter="name:$CLUSTER_NAME" --format="value(name,zone)" | \
while read -r disk_name zone; do \
  gcloud compute disks delete "$disk_name" --zone="$zone" --quiet \
done
```

## Verify Cleanup

```shell
gcloud container clusters list

gcloud container node-pools list --cluster=$CLUSTER_NAME --zone=$ZONE

gcloud compute disks list --filter="name:$CLUSTER_NAME"
```