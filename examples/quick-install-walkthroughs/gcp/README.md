# __Install Tercen On Google Kubernetes Engine__

Based From this Google Tutorial
https://cloud.google.com/kubernetes-engine/docs/tutorials/persistent-disk

----
## Create a GKE Cluster

## 1. Go to Google Cloud


## 2. Select Your Project


## 3. Activate Cloud Shell

## 4. Set active GCP Zone in Command Line

#### Command
gcloud config set compute/zone {zone}
e.g.
gcloud config set compute/zone europe-west2-a

## 5. Set ProjectID
#### Command
export PROJECT_ID={project-id}
e.g
export PROJECT_ID=martin1-296614

## 6. Upload Tercen manifest files to Cloud Sheel Session
git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples
(change to tercen files)

## 7. Go to tutorial directory
cd kubernetes-engine-samples/wordpress-persistent-disks

## 8. Set the working directory environment variable 

#### Command
WORKING_DIR=$(pwd)

## 9. Create cluster
This will create a cluster with two worker nodes in two compute zones for HA. You can adjust the variables in the command to configure the cluster to your own specification. See Google documentation for instructions. 

#### Command
Choose a name for your cluster it will be used in later commands in this tutorial.
e.g
$CLUSTER_NAME=tercen

$COMPUTE_ZONES = europe-west2-a,europe-west2-b

#### Command
gcloud container clusters create $CLUSTER_NAME  --num-nodes=2 --node-locations $COMPUTE_ZONES --enable-autoupgrade --no-enable-basic-auth --no-issue-client-certificate --enable-ip-alias --metadata disable-legacy-endpoints=true

e.g
gcloud container clusters create tercen  --num-nodes=3 --enable-autoupgrade --no-enable-basic-auth --no-issue-client-certificate --enable-ip-alias --metadata disable-legacy-endpoints=true

You may be required to Authorise the cloud shell.

----

## Install CouchDB

## 10. Create CouchDB Persistant Volume claim

#### Command
kubectl apply -f $WORKING_DIR/couchdb-pv-claim-stage.yaml

## 11. Deploy CouchDB
Upload file to working directory.

kubectl apply -f $WORKING_DIR/couchdb-stage.yaml

Check deployment.
kubectl get persistentvolumeclaim


## 11. Test CouchDB install 
This test will use port forwarding to open a connection to the test browser of the Cloud Shell 

#### Command
kubectl get pods
Copy the couchdb pod name to a text file. It will be used in a later command under the variable $COUCHDB_POD.
e.g
couchdb-stage-789d9d4b6d-tfzf8

#### Command
kubectl port-forward $COUCHDB_POD 5984:5984
e.g
kubectl port-forward couchdb-stage-789d9d4b6d-tfzf8 5984:5984

Click the web preview icon at the top right of the Cloud Shell Editor

Change the port to 5984

A Browser tab will open showing test as follows.
e.g
{"couchdb":"Welcome","uuid":"56c45cc839391fab7bcc2410cbe0acee","version":"1.7.2","vendor":{"name":"The Apache Software Foundation","version":"1.7.2"}}

Return to the Terminal window and press Ctrl+C to quit port forwarding.

----

## Deploy Tercen

## 12. Create Tercen Service

#### Command
kubectl apply -f $WORKING_DIR/tercen-stage-service.yaml

----------------------------------------------------------------------------
## 13. Configure Tercen base settings (check with alex)

#### Command
kubectl create configmap tercen-staging-config --from-file=config.yaml=tercen-staging-config.yaml -o yaml --dry-run=client >> tercen-staging-config.yaml.run

(Note: This file corrupted on upload to Cloud Shell - retest with GitHub Clone)

kubectl create configmap tercen-staging-config --from-file=config.yaml=tercen-staging-config.yaml -o yaml

#### Command
kubectl apply -f tercen-staging-config.yaml --validate=false

(note: error messages check with Alex)

-----------------------------------------------------------------------------------

## 13. Configure Tercen base settings

#### Command
kubectl create configmap tercen-staging-config --from-file=config.yaml=tercen-staging-config.yaml -o yaml

kubectl describe configmaps tercen-staging-config

## 14. Create Tercen PV Claim

kubectl apply -f tercen-pv-claim-stage.yaml

## 15. Deploy Tercen
Tercen may take a few minutes to deploy.

#### Command
kubectl apply -f tercen-stage-deployment.yaml\


## 16. Expose Tercen to external Load balancer

#### Command
kubectl apply -f tercen-loadbalancer.yaml


## 17. Test Tercen Deployment

#### Command
kubectl get service


Copy the Loadbalancer EXTERNAL-IP address 

Paste this IP Address into a browser.

----

Refer to Delete Cluster Instructions.txt when removing this deployment.