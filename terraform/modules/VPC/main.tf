resource "aws_vpc" "demo_eks_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = "demo-eks-${var.env}-vpc"
    }
}

resource "aws_internet_gateway" "demo_eks_ig" {
    region = "us-east-1"
    tags = {
      Name = "demo-eks-${var.env}-IG"
    }
}

resource "aws_internet_gateway_attachment" "demo_eks_ig_attach" {
    vpc_id = aws_vpc.demo_eks_vpc.id
    internet_gateway_id = aws_internet_gateway.demo_eks_ig.id
}

resource "aws_subnet" "demo_eks_public_subnet_1" {
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    vpc_id = aws_vpc.demo_eks_vpc.id
    map_public_ip_on_launch = true
    tags = {
        Name = "demo-eks-public-${var.env}-SN-1"
    }
}

resource "aws_subnet" "demo_eks_public_subnet_2" {
    cidr_block = "10.0.3.0/24"
    vpc_id = aws_vpc.demo_eks_vpc.id
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
      Name = "demo-eks-public-${var.env}-SN-2"
    }
}

resource "aws_subnet" "demo_eks_private_subnet_1" {
  cidr_block = "10.0.5.0/24"
  vpc_id = aws_vpc.demo_eks_vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "demo-eks-private-${var.env}-SN-1"
  }
}

resource "aws_subnet" "demo_eks_private_subnet_2" {
  cidr_block = "10.0.7.0/24"
  vpc_id = aws_vpc.demo_eks_vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "demo-eks-private-${var.env}-SN-2"
  }
}

resource "aws_eip" "demo_eks_nat_ip" {
    domain = "vpc"
    tags = {
      Name = "demo-eks-${var.env}-nat-eip"
    }
}

resource "aws_nat_gateway" "demo_eks_nat_g" {
    subnet_id = aws_subnet.demo_eks_public_subnet_1.id
    allocation_id = aws_eip.demo_eks_nat_ip.allocation_id
    availability_mode = "zonal"
    tags = {
      Name = "demo-eks-${var.env}-nat-gateway"
    }
}

resource "aws_route_table" "demo_eks_public_route_table" {
    vpc_id = aws_vpc.demo_eks_vpc.id
    tags = {
        Name = "demo-eks-${var.env}-public-RT"
    }
}

resource "aws_route" "demo_eks_public_route" {
    route_table_id = aws_route_table.demo_eks_public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_eks_ig.id
}

resource "aws_route_table_association" "demo_eks_public_SN_asso" {
    for_each = { 
        pub_subnet_1 = aws_subnet.demo_eks_public_subnet_1.id, 
        pub_subnet_2 = aws_subnet.demo_eks_public_subnet_2.id 
    }
    route_table_id = aws_route_table.demo_eks_public_route_table.id
    subnet_id = each.value
}

resource "aws_route_table" "demo_eks_private_route_table" {
    vpc_id = aws_vpc.demo_eks_vpc.id
    tags = {
      Name = "demo-eks-${var.env}-private-RT"
    }
}

resource "aws_route" "demo_eks_private_route" {
    route_table_id = aws_route_table.demo_eks_private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.demo_eks_nat_g.id
}

resource "aws_route_table_association" "demo_eks_private_SN_asso" {
    route_table_id = aws_route_table.demo_eks_private_route_table.id
    for_each = { 
        pri_subnet_1 = aws_subnet.demo_eks_private_subnet_1.id, 
        pri_subnet_2 = aws_subnet.demo_eks_private_subnet_2.id 
    }
    subnet_id = each.value
}

