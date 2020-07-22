# find the newest nginx-demo ami
data "aws_ami" "nginx-demo" {
  count = var.create_instance ? 1 : 0
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["nginx-demo-*"]
  }
}

# find the route53 zone
data "aws_route53_zone" "selected" {
  name         = "beta-seattle.net."
}

# instance profile to add the decrypt role
resource "aws_iam_instance_profile" "decrypt_profile" {
  name = "decrypt_profile_${var.region}"
  role = aws_iam_role.cert_decrypt_role.name
}

# create our web server
resource "aws_instance" "web1" {
    count = var.create_instance ? 1 : 0
    ami = data.aws_ami.nginx-demo[count.index].id
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.decrypt_profile.name
    subnet_id = aws_subnet.presentation-subnet-public-1.id
    vpc_security_group_ids = [ aws_security_group.web-open.id ]
}

# associate an elastic IP
resource "aws_eip" "web_eip" {
  count = var.create_instance ? 1 : 0
  instance = aws_instance.web1[count.index].id
  vpc      = true
}

# create an A record
resource "aws_route53_record" "www" {
  count = var.create_instance ? 1 : 0
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.region}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = [ aws_eip.web_eip[count.index].public_ip ]
}