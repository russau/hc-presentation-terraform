
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "russ@tinisles.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "tls.beta-seattle.net"

  dns_challenge {
    provider = "route53"
  }
}

resource "aws_kms_key" "cert_key" {
  description = "cert key"
  is_enabled  = true
}

resource "aws_kms_ciphertext" "cert_private_key" {
  key_id = aws_kms_key.cert_key.key_id

  plaintext = acme_certificate.certificate.private_key_pem
}

output "web_certificate_pem" {
  value = acme_certificate.certificate.certificate_pem
}

output "web_issuer_pem" {
  value = acme_certificate.certificate.issuer_pem
}

output "web_cert_private_key_ciphertext" {
  value = aws_kms_ciphertext.cert_private_key.ciphertext_blob
}