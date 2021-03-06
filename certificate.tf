# create an RSA key to authenticate to Let's Encrypt
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# register with Let's Encrypt
resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "russ@tinisles.com"
}

# request a cert from Let's Encrypt, a TXT record on route 53 is used for domain verification
resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "${var.region}.beta-seattle.net"

  dns_challenge {
    provider = "route53"
  }
}

# create a KMS key
resource "aws_kms_key" "cert_key" {
  description = "cert key"
  is_enabled  = true
}

# encrypt the private portion of our Let's Encrypt key
resource "aws_kms_ciphertext" "cert_private_key" {
  key_id = aws_kms_key.cert_key.key_id

  plaintext = acme_certificate.certificate.private_key_pem
}

# create an ec2 role
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# role can decrypt the private key
resource "aws_iam_role" "cert_decrypt_role" {
  name               = "cert_decrypt_role_${var.region}"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_role_policy" "cert_decrypt_policy" {
  name = "cert_decrypt_policy_${var.region}"
  role = aws_iam_role.cert_decrypt_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "kms:Decrypt",
        "Effect": "Allow",
        "Resource": "${aws_kms_key.cert_key.arn}"
      }
    ]
  }
  EOF
}

# Output everything needed to configure nginix SSL config
output "web_certificate_pem" {
  value = acme_certificate.certificate.certificate_pem
}
output "web_issuer_pem" {
  value = acme_certificate.certificate.issuer_pem
}
output "web_cert_private_key_ciphertext" {
  value = aws_kms_ciphertext.cert_private_key.ciphertext_blob
}