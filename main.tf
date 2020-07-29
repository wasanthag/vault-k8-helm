data "local_file" "vault_ca" {
  filename = var.vault_ca
}

data "local_file" "vault_crt" {
  filename = var.vault_crt
}

data "local_file" "vault_key" {
  filename = var.vault_key
}

data "local_file" "gcp_creds" {
  filename = var.gcp_creds
}

resource "kubernetes_secret" "vault-tls" {
  metadata {
    name      = "vault-tls"
    namespace = "default"
  }

  data = {
    "vault_ca"  = data.local_file.vault_ca.content
    "vault_crt" = data.local_file.vault_crt.content
    "vault_key" = data.local_file.vault_key.content
  }

  type = "Opaque"
}

resource "kubernetes_secret" "kms-creds" {
  metadata {
    name      = "kms-creds"
    namespace = "default"
  }

  data = {
    "credentials.json" = data.local_file.gcp_creds.content
  }

  type = "Opaque"
}


resource "helm_release" "vault" {
  name  = "vault"
  chart = "hashicorp/vault"
  values = [
    "${file("values-raft-nogkms.yaml")}"
  ]
}
resource "null_resource" "cleanup_pvc0" {
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "kubectl delete pvc data-vault-0"
  }
}
resource "null_resource" "cleanup_pvc1" {
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "kubectl delete pvc data-vault-1"
  }
}
resource "null_resource" "cleanup_pvc2" {
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "kubectl delete pvc data-vault-2"
  }
}
