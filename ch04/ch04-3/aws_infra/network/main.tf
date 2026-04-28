
resource "aws_vpc" "aws10-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.prefix}vpc"
    }
}

resource "aws_subnet" "aws10-public-subnet" {
    count = length(var.public_subnet_cidr_block)
    vpc_id = aws_vpc.aws10-vpc.id
    cidr_block = var.public_subnet_cidr_block[count.index]
    availability_zone = var.availability_zone[count.index]
    tags = {
        Name = "${var.prefix}public-subnet-${count.index + 1}"
    }
}

resource "aws_subnet" "aws10-private-subnet" {
    count = length(var.private_subnet_cidr_block)
    vpc_id = aws_vpc.aws10-vpc.id
    cidr_block = var.private_subnet_cidr_block[count.index]
    availability_zone = var.availability_zone[count.index]
    tags = {
        Name = "${var.prefix}private-subnet-${count.index + 1}"
    }
}

resource "aws_internet_gateway" "aws10-igw" {
    vpc_id = aws_vpc.aws10-vpc.id
    tags = {
        Name = "${var.prefix}igw"
    }
}
resource "aws_eip" "aws10-nat-eip" {
    count = length(var.public_subnet_cidr_block)
    domain = "vpc"
    tags = {
        Name = "${var.prefix}nat-eip"
    }
}
resource "aws_nat_gateway" "aws10-nat-gw" {
    count = length(var.public_subnet_cidr_block)
    allocation_id = aws_eip.aws10-nat-eip[count.index].id
    subnet_id = aws_subnet.aws10-public-subnet[count.index].id
    tags = {
        Name = "${var.prefix}nat-gw"
    }
    depends_on = [aws_eip.aws10-nat-eip]
}
resource "aws_route_table" "aws10-public-rt" {
    vpc_id = aws_vpc.aws10-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.aws10-igw.id
    }
    tags = {
        Name = "${var.prefix}public-rt"
    }
}
resource "aws_route_table_association" "aws10-public-rt-association" {
    count = length(var.public_subnet_cidr_block)
    subnet_id = aws_subnet.aws10-public-subnet[count.index].id
    route_table_id = aws_route_table.aws10-public-rt.id
}
resource "aws_route_table" "aws10-private-rt" {
    count = length(var.private_subnet_cidr_block)
    vpc_id = aws_vpc.aws10-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.aws10-nat-gw[count.index].id
    }
    tags = {
        Name = "${var.prefix}private-rt-${count.index + 1}"
    }
}
resource "aws_route_table_association" "aws10-private-rt-association" {
    count = length(var.private_subnet_cidr_block)
    subnet_id = aws_subnet.aws10-private-subnet[count.index].id
    route_table_id = aws_route_table.aws10-private-rt[count.index].id
}
resource "aws_security_group" "aws10-ssh-sg" {
    name = "${var.prefix}-ssh-sg"
    description = "Allow SSH access"
    vpc_id = aws_vpc.aws10-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "aws10-http-sg" {
    name = "${var.prefix}-http-sg"
    description = "Allow HTTP access"
    vpc_id = aws_vpc.aws10-vpc.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}