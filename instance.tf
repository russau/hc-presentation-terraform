# find the newest nginx-demo ami
data "aws_ami" "nginx-demo" {
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

# create our web server
resource "aws_instance" "web1" {
    ami = data.aws_ami.nginx-demo.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.presentation-subnet-public-1.id
    vpc_security_group_ids = [ aws_security_group.web-open.id ]
}

# associate an elastic IP
resource "aws_eip" "web_eip" {
  instance = aws_instance.web1.id
  vpc      = true
}

# create an A record
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.region}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = [ aws_eip.web_eip.public_ip ]
}

# output a link to the web server and the AMI used
output "web_ip_addr" {
  value = "http://${aws_route53_record.www.fqdn}"
}
output "web_ami_id" {
  value = data.aws_ami.nginx-demo.id
}