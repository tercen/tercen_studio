# __Install Tercen On AWS__
This instruction pre-supposes you will be using Kubernetes version 1.16 or later.
Variables in commands are replesented as follows $AWS_REGION you must replace the variable name with the information
that is relevant for your deployment. An example is included but some familiarity with AWS concepts is useful. 

## Software to be Pre-Installed
Click on the links to go to AWS instructions for installing each.
[Kubectl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html#eksctl-gs-install-kubectl)
[AWS CLI](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html#install-awscli)
[eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html#install-eksctl)

__For Windows__
Folder where commands are executed from must be on [PATH](https://docs.alfresco.com/4.2/tasks/fot-addpath.html)

Recomended install [Chocolatey](https://chocolatey.org/) package manager

----
## Create Cluster

## 1. Create cluster with eksctl EC2 nodes
This will create a cluster with defaul two M5.large nodes. 
They will deploy into two seperate availability zones for HA.
If you wish to change this see eksctl documentation for configuration properties options. 

#### Command
```bash
eksctl create cluster --name $CLUSTER_NAME --region $AWS_REGION
```

e.g.
```bash
eksctl create cluster --name martin18 --region eu-west-1
```

## 2. Create IAM OIDC provider for your cluster


#### Command
```bash
_eksctl utils associate-iam-oidc-provider --region $AWS_REGION --cluster $CLUSTER_NAME --approve_
```

e.g.
```bash
eksctl utils associate-iam-oidc-provider --region eu-west-1 --cluster martin18 --approve
```

----
## Set up Load Balancer


## 3. Create IAM policy for Load Balancer
A copy of this policy has been included in this GitHub repository. If an updated policy is needed the link is included below.

Download Policy
```bash
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/main/docs/install/iam_policy.json)
```

Create Policy
```bash
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json
```

From the text output by the terminal copy the Policy ARN to a text file. 
It will be used in a later command under the variable $ALB_POLICY. 
You can also copy it from the AWS Control Panel.

e.g.
```bash
arn:aws:iam::334845943767:policy/AWSLoadBalancerControllerIAMPolicy
```

## 4. Create IAM Role and Service Account for cluster

#### Command
```bash
eksctl create iamserviceaccount --cluster=$CLUSTER_NAME --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=$ALB_POLICY --approve
```

e.g.
```bash
eksctl create iamserviceaccount --cluster=martin18 --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::334845943767:policy/AWSLoadBalancerControllerIAMPolicy --approve
```

## 5. Install Cert Manager to cluster

#### Command
```bash
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml
```

## 6. Apply Load Balancer Controller Service Yaml
Before applying the next command you must edit the v2_0_0_full.yaml file to have your current cluster name 
Search in the fole for the following line. [--cluster-name=<clustername>]) and change <clustername> to be $CLUSTER_NAME

#### Command
```bash
kubectl apply -f v2_0_0_full.yaml
```

----

## 7. Check the Deployment
Note ALB takes some time to deploy and may return no values for the first few minutes.

#### Command
```bash
kubectl get pods --all-namespaces
```

Copy load balancer controller name to a text file. 
It will be used in a later command under the variable $LOAD_BALANCER

e.g.
```bash
aws-load-balancer-controller-556f9b8d97-kckqk
```

#### Command
```bash
kubectl logs $LOAD_BALANCER -n kube-system
```

e.g.
```bash
kubectl logs aws-load-balancer-controller-556f9b8d97-kckqk -n kube-system
```

 
You can check each line is an "info" line and there are no "error" lines.

----
## Set up persistant storage with Elastic Block Storage   


## 8. Create policy to allow nodes modify EBS Volumes
A copy of this policy has been included in this GitHub repository. If an updated policy is needed the link is included below.

Download Policy
```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.4.0/docs/example-iam-policy.json)
```

#### Command
```bash
aws iam create-policy --policy-name Amazon_EBS_CSI_Driver --policy-document file://example-iam-policy.json
```

From the text output by the terminal, copy the Policy ARN to a text file. 
It will be used in a later command under the variable $EBS_POLICY. 

You can also copy it from the AWS Control Panel.

e.g.
```bash
arn:aws:iam::334845943767:policy/Amazon_EBS_CSI_Driver
```

## 9. Attach policy to NodeInstanceRole
eksctl has created a NodeInstanceRole for the cluster. 
You must copy the node name to a text file. 
It will be used in a later command under the variable $NODE_NAME. 
The node name can be found on the AWS Control Panel under IAM > Roles. 
Enter "node" in the search box. You will find the role ARN, which contains the node name.

e.g. 
```bash
Role ARN = arn:aws:iam::334845943767:role/**eksctl-martin18-nodegroup-ng-1518-NodeInstanceRole-PHM92HFNFP6U**
```

```bash
$NODE_NAME = eksctl-martin18-nodegroup-ng-1518-NodeInstanceRole-PHM92HFNFP6U
```

#### Command
```bash
aws iam attach-role-policy --policy-arn $EBS_POLICY --role-name NODE_NAME
```

e.g.
```bash
aws iam attach-role-policy --policy-arn arn:aws:iam::334845943767:policy/Amazon_EBS_CSI_Driver --role-name eksctl-martin18-nodegroup-ng-1518-NodeInstanceRole-PHM92HFNFP6U
```

The terminal will give no output message but success can be checked on the AWS Control Panel at IAM > Policies > Amazon_EBS_CSI_Driver > Policy Usage).
You will see the $NODE_NAME attached here.

## 10. Deploy Amazon EBS CSI driver

#### Command
```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```

----
## Install CouchDB

## 11. Create Persistant Volume Claim on EBS

#### Command
```bash
kubectl apply -f couchdb-pv-claim-stage.yaml
```

## 12. Create Couchdb Service & Deployment

#### Command
```bash
kubectl apply -f couchdb-stage.yaml
```

## 13. Test CouchDB install 
This test will use port forwarding to open a connection between a browser on your localhost and the admin console panel of Couchdb 

#### Command
```bash
kubectl get pods
```

Copy the couchdb pod name to a text file. It will be used in a later command under the variable $COUCHDB_POD.

e.g.
```bash
couchdb-stage-789d9d4b6d-zwd5v
```

#### Command
```bash
kubectl port-forward $COUCHDB_POD 5984:5984
```

# e.g.
```bash
kubectl port-forward couchdb-stage-789d9d4b6d-zwd5v 5984:5984
```

Copy the IP address of the local host port to a text file as the variable $PTFWD_COUCHDB.

e.g.
```bash
127.0.0.1:5984
```

Open browser and enter the following

```bash
http://$PTFWD_COUCHDB/_utils/
```

e.g.
```bash
http://127.0.0.1:5984/_utils/
```

You will see the couchdb control panel. 
Return to the terminal where Ctrl+C will quit port forwarding and allow further commands to be entered.

----

## Deploy Tercen

## 14. Create Tercen Service

#### Command
```bash
kubectl apply -f tercen-stage-service.yaml
```

## 15. Configure Tercen base settings.

#### Command
```bash
kubectl create configmap tercen-staging-config --from-file=config.yaml=tercen-staging-config.yaml -o yaml --dry-run > tercen-staging-k8s-config.yaml
```

#### Command
```bash
kubectl apply -f tercen-staging-k8s-config.yaml
```

Tercens default passwords may be retreived from the file for first use.

#### Command
```bash
kubectl describe configmaps tercen-staging-config
```

## 16. Create Tercen Persistant Volume Claim

#### Command
```bash
kubectl apply -f tercen-pv-claim-stage.yaml
```

## 17. deploy Tercen
```bash
kubectl apply -f tercen-stage-deployment.yaml
```

## 18. Test Tercen install.
This test will use port forwarding to open a connection between a browser on your localhost and the sign-in page of Tercen.

#### Command
```bash
kubectl get pods
```

Copy the Tercen pod name to a text file. It will be used in a later command under the variable $TERCEN_POD.

e.g.
```bash
tercen-stage-deployment-6cd88ff877-9plwz
```
#### Command
```bash
kubectl port-forward $TERCEN_POD 5400:5400
```

e.g.
```bash
kubectl port-forward tercen-stage-deployment-6cd88ff877-9plwz 5400:5400
```
Copy the IP address of the local host port to a text file as the variable $PTFWD_TERCEN

e.g.
```bash
127.0.0.1:5984
```

Open browser and enter the following

```bash
http://$PTFWD_TERCEN/
```

e.g.
```bash
http://127.0.0.1:5400
```

You will see the Tercen sign-in page. 
Return to the terminal where Ctrl+C will quit port forwarding and allow further commands to be entered.

## 19. Create Tercen ingress to the Load Balancer

#### Command
```bash
kubectl apply -f tercen-ingress.yaml
```

## 20. Connect to Tercen Install.

#### Command
```bash
kubectl describe ingress --all-namespaces
```

The terminal will return information on the state of the load balancer. One of the values retuirned will be labeled "Address"

e.g.
```bash
Address: k8s-default-ingresst-13bd8c2839-169780088.eu-west-1.elb.amazonaws.com
```

Copy Address to your browser. 

Tercen is now running on your kubernetes cluster and is accessable through the internet. 

----
## Option 1: Delete Installation
See deletion instructions for removing your Tercen kubernetes installation from AWS

----
## Option 2: Connect ALB to Route 53.
The Address returned by the load balancer can be added to DNS records at your provider to provide a URL to access Tercen. 
These instruction are if you have a Domain hoster by AWS Route53 service.

From Control Panel

Route 53 > Hosted Zones > Select Domain > Create Record > Routing policy > Set Record Name

Value/Route traffic to = Alias to Application and Classic Load Balancer

Select region (e.g. eu-west-1)

Kubernetes cluster Load balancer now will be available to select

Record Type = A
