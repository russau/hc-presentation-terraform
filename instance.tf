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
