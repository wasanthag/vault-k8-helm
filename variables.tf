variable "vault_ca" {
  description = "vault CA file"
  default     = "vault_ca_cert.pem"
}
variable "vault_crt" {
  description = "vault self signed cert file"
  default     = "vault_cert.pem"
}
variable "vault_key" {
  description = "vault self sign key file"
  default     = "vault_private_key.pem"
}
variable "gcp_creds" {
  description = "gcp kms service account key file"
  default     = "credentials.json"
}
variable "cluster_size" {
  description = "vault cluster size"
  default     = 3
}
