# vault-k8-helm
This repository contains the Terraform code to deploy HashiCorp Vault with raft storage backend in to a GKE K8s cluster using Terraform Helm provider.

## GCP Prep work
Create GCP KMS,IAM and Service Account resources required and create GKE K8s cluster if not already available.

```
$ gcloud services enable \
    cloudapis.googleapis.com \
    cloudkms.googleapis.com \
    cloudresourcemanager.googleapis.com \
    cloudshell.googleapis.com \
    container.googleapis.com \
    containerregistry.googleapis.com \
    iam.googleapis.com

$ gcloud kms keyrings create vault \
    --location us-east1

$ gcloud kms keys create vault-init \
    --location us-east1 \
    --keyring vault \
    --purpose encryption

$ export GOOGLE_CLOUD_PROJECT="<project>"

$ export SERVICE_ACCOUNT="vault-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

$ gcloud iam service-accounts create vault-server \
    --display-name "vault service account"

$ gcloud kms keys add-iam-policy-binding vault-init \
    --location us-east1 \
    --keyring vault \
    --member "serviceAccount:${SERVICE_ACCOUNT}" \
    --role roles/cloudkms.cryptoKeyEncrypterDecrypter

$ gcloud container clusters create vault \
    --cluster-version 1.16 \
    --enable-autorepair \
    --enable-autoupgrade \
    --enable-ip-alias \
    --machine-type n1-standard-1 \
    --node-version 1.16 \
    --num-nodes 1 \
    --region us-east1 \
    --scopes cloud-platform \
    --service-account "vault-server@{GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

```

## Create Certificates
use the git repo https://github.com/wasanthag/generate-self-sign-cert to create CA cert, server cert and a private key. Copy them over to this directory.

## Run the Terraform code
```terraform apply -auto-approve```
This should create the Vault cluster.

## Execute the following commands

### Initialize the Vault on node 1
```
kubectl exec -it vault-0 sh
vault status
vault operator init
vault status
export VAULT_TOKEN=<value from above>
vault operator raft list-peers
```
### Add Vault node 2 and 3 to the raft cluster
```
vault operator raft join -leader-ca-cert="$(cat /vault/userconfig/vault-tls/vault_ca)" --address "https://vault-1.vault-internal:8200" "https://vault-0.vault-internal:8200"
vault operator raft join -leader-ca-cert="$(cat /vault/userconfig/vault-tls/vault_ca)" --address "https://vault-2.vault-internal:8200" "https://vault-0.vault-internal:8200"
vault operator raft list-peers
```
