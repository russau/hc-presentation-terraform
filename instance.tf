
resource "aws_instance" "web1" {
    ami = "ami-000e9db38e7ef9e37" // remove hardcoding
    instance_type = "t2.micro"
    # VPC
    subnet_id = aws_subnet.presentation-subnet-public-1.id
    vpc_security_group_ids = [ aws_security_group.web-open.id ]
}
