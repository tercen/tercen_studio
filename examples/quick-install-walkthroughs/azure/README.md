# Install Tercen on Microsoft AKS Cluster
This instruction uses the Cloud Shell function in Azure. 

The cloud shell has most of the CLI resources (such as kubectl) pre-loaded.

Tutorial:
https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough


Some commands have variables where you will have to name objects such as your cluster and then use that name in subsequent commands

The variables are represented in this text with a $. 

e.g.
$VARIABLE

It is advisable that you save your variable names into a text file for use in commands.

----

## 1. Create a Resource Group to hold the cluster.

To list the Azure Region Names and choose the one nearest your location

#### Command
```Bash
az account list-locations -o table
```

#### Command
```Bash
az group create --name $RESOURCE NAME --location $REGION NAME
```

e.g.
```Bash
az group create --name myResourceGroup --location northeurope
```

## 2. Register to Container Monitoring Service (Optional)
This will send cluster health and load monitoring information to the Azure Monitor Dashboard.

#### Command
```Bash
az provider register --namespace Microsoft.OperationsManagement

az provider register --namespace Microsoft.OperationalInsights
```

## 3. Create AKS Cluster
This will create a cluster with a single worker node in two. You can adjust the variables in the command to configure the cluster to your own specification. See Azure documentation for instructions. 

#### Command
```Bash
az aks create --resource-group $RESOURCE NAME --name $CLUSTER NAME --node-count 1 --enable-addons monitoring --generate-ssh-keys
```

e.g.
```Bash
az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
```

## 4. Connect to the cluster


#### Command
```Bash
az aks get-credentials --resource-group $RESOURCE NAME --name $CLUSTER NAME
```

e.g.
```Bash
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

Verify a successful connection with a kubectl command

e.g.
```Bash
kubectl get nodes
```

## 4. Upload Files to Cloud Shell environment

git clone https://github.com/tercen/tercen_studio/tree/master/examples/quick-install-walkthroughs/azure

## 5. Create Storage Class.

#### Command
```Bash
kubectl apply -f azure-file-sc.yaml
```
-----

## Install CouchDB 

## 6. Create CouchDB Persistent Volume Claim

#### Command
```Bash
kubectl apply -f couchdb-pv-claim.yaml
```

## 7. Deploy CouchDB

#### Command
```Bash
kubectl apply -f couchdb-stage.yaml
```

Check deployment.
```Bash
kubectl get persistentvolumeclaim
```

## 8. Test CouchDB install 
This test will use port forwarding to open a connection to the test browser of the Cloud Shell 

#### Command
```Bash
kubectl get pods
```

Copy the couchdb pod name to a text file. It will be used in a later command under the variable $COUCHDB_POD.

e.g.
couchdb-stage-6d9fff7f98-vlcsc

#### Command
```Bash
kubectl port-forward $COUCHDB_POD 5984:5984
```

e.g.
```Bash
kubectl port-forward couchdb-stage-6d9fff7f98-vlcsc 5984:5984
```

Click the web preview icon at the right of the Cloud Shell Editor tool bar.  

Configure the port to 5984

Click the web preview icon again and select the option "Preview port 5984"  

A Browser tab will open showing text as follows.
 
e.g.
{"couchdb":"Welcome","uuid":"56c45cc839391fab7bcc2410cbe0acee","version":"1.7.2","vendor":{"name":"The Apache Software Foundation","version":"1.7.2"}}

Return to the Terminal window and press Ctrl+C to quit port forwarding.

-----

## Deploy Tercen

## 9. Create Tercen Service

#### Command
```Bash
kubectl apply -f tercen-stage-service.yaml
```

## 10. Configure Tercen base settings 
These commands post the basic settings into the Tercen config file and then apply them to the cluster.

If you need to change Tercens default values change the tercen-staging-config.yaml and then follow the commands below.


To apply your new settings to config file.
```bash
kubectl create configmap tercen-staging-config --from-file=config.yaml=tercen-staging-config.yaml -o yaml --dry-run > tercen-staging-k8s-config.yaml
```

To apply config file to cluster
Skip previous step is using default values.

#### Command
```bash
kubectl apply -f tercen-staging-k8s-config.yaml
```
Check successful configuration.
```Bash
kubectl describe configmaps tercen-staging-config
```

Tercens settings will appear on screen.

## 11. Create Tercen PV Claim

#### Command
```Bash
kubectl apply -f tercen-pv-claim-stage.yaml
```

## 12. Deploy Tercen
Tercen may take a few minutes to deploy.

#### Command
```Bash
kubectl apply -f tercen-stage-deployment.yaml
```

## 13. Expose Tercen to external Load balancer

#### Command
```Bash
kubectl apply -f tercen-loadbalancer.yaml
```

## 14. Test Tercen Deployment

#### Command
```Bash
kubectl get service
```

Copy the Loadbalancer EXTERNAL-IP address 

Paste this IP Address into a browser.

----

Refer to Delete Cluster Instructions.txt when removing this deployment.