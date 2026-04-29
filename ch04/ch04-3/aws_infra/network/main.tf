
resource "aws_vpc" "aws10_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.prefix}-vpc"
    }
}

resource "aws_subnet" "aws10_public_subnet" {
    count = length(var.public_subnet_cidr_block)
    vpc_id = aws_vpc.aws10_vpc.id
    cidr_block = var.public_subnet_cidr_block[0]
    availability_zone = var.availability_zone[0]
    tags = {
        Name = "${var.prefix}-public-subnet-${count.index + 1}"
    }
}

resource "aws_subnet" "aws10_private_subnet" {
    count = length(var.private_subnet_cidr_block)
    vpc_id = aws_vpc.aws10_vpc.id
    cidr_block = var.private_subnet_cidr_block[count.index]
    availability_zone = var.availability_zone[count.index]
    tags = {
        Name = "${var.prefix}-private-subnet-${count.index + 1}"
    }
}

resource "aws_internet_gateway" "aws10_igw" {
    vpc_id = aws_vpc.aws10_vpc.id
    tags = {
        Name = "${var.prefix}-igw"
    }
}

resource "aws_eip" "aws10_nat_eip" {
    domain = "vpc"
    tags = {
        Name = "${var.prefix}-nat-eip"
    }
}

resource "aws_nat_gateway" "aws10_nat_gw" {
    allocation_id = aws_eip.aws10_nat_eip.id
    subnet_id = aws_subnet.aws10_public_subnet.id
    tags = {
        Name = "${var.prefix}-nat-gw"
    }
    depends_on = [aws_eip.aws10_nat_eip]
}

resource "aws_route_table" "aws10_public_rt" {
    vpc_id = aws_vpc.aws10_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.aws10_igw.id
    }
    tags = {
        Name = "${var.prefix}-public-rt"
    }
}

resource "aws_route_table_association" "aws10_public_rt_association" {
    count = length(var.public_subnet_cidr_block)
    subnet_id = aws_subnet.aws10_public_subnet.id
    route_table_id = aws_route_table.aws10_public_rt.id
}

resource "aws_route_table" "aws10_private_rt" {
    count = length(var.private_subnet_cidr_block)
    vpc_id = aws_vpc.aws10_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.aws10_nat_gw.id
    }
    tags = {
        Name = "${var.prefix}-private-rt-${count.index + 1}"
    }
}

resource "aws_route_table_association" "aws10_private_rt_association" {
    count = length(var.private_subnet_cidr_block)
    subnet_id = aws_subnet.aws10_private_subnet[count.index].id
    route_table_id = aws_route_table.aws10_private_rt[count.index].id
}

resource "aws_security_group" "aws10_ssh_sg" {
    name = "${var.prefix}-ssh-sg"
    description = "Allow SSH access"
    vpc_id = aws_vpc.aws10_vpc.id
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
    tags = {
        Name = "${var.prefix}-ssh-sg"
    }
}

resource "aws_security_group" "aws10_http_sg" {
    name = "${var.prefix}-http-sg"
    description = "Allow HTTP access"
    vpc_id = aws_vpc.aws10_vpc.id
    dynamic "ingress" {
        for_each = [80, 443]
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
        egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.prefix}-http-sg"
    }
}