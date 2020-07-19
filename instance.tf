data "aws_ami" "nginx-demo" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["nginx-demo-*"]
  }
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

output "web_ip_addr" {
  value = aws_eip.web_eip.public_ip
}