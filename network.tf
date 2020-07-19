resource "aws_internet_gateway" "presentation-igw" {
    vpc_id = aws_vpc.presentation-vpc.id
    tags = {
        Name = "presentation-igw"
    }
}

resource "aws_route_table" "presentation-public-crt" {
    vpc_id = aws_vpc.presentation-vpc.id
    
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.presentation-igw.id
    }
    
    tags = {
        Name = "presentation-public-crt"
    }
}

resource "aws_route_table_association" "presentation-crta-public-subnet-1"{
    subnet_id = aws_subnet.presentation-subnet-public-1.id
    route_table_id = aws_route_table.presentation-public-crt.id
}