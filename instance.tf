data "aws_ami" "nginx-demo" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["nginx-demo-*"]
  }
}

data "aws_route53_zone" "selected" {
  name         = "beta-seattle.net."
}

resource "aws_instance" "web1" {
    ami = data.aws_ami.nginx-demo.id
    instance_type = "t2.micro"
    # VPC
    subnet_id = aws_subnet.presentation-subnet-public-1.id
    vpc_security_group_ids = [ aws_security_group.web-open.id ]
}

resource "aws_eip" "web_eip" {
  instance = aws_instance.web1.id
  vpc      = true
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "tls.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = [ aws_eip.web_eip.public_ip ]
}

output "web_ip_addr" {
  value = "http://tls.${data.aws_route53_zone.selected.name}"
}

output "web_ami_id" {
  value = data.aws_ami.nginx-demo.id
}