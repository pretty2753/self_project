# 테라폼 버전================================================================== 
terraform {
  required_version = "~>1.14.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}
# aws 리전 설정 ===============================================================

provider "aws" {
    region = "ap-northeast-2"
}

# vpc 설정 ====================================================================
resource "aws_vpc" "main_vpc" {
    cidr_block              = "20.0.0.0/16"
    enable_dns_hostnames    = true # 인스턴스에 dns 이름을 부여 하기 위해 활성화
    enable_dns_support      = true
    tags = {
        Name                = "self-practice-vpc1"
    }
}
# 가용영역 및 subnet 설정 ======================================================
data "aws_availability_zones" "available"{ # 가용영역 데이터 가져오기
    state = "available" 
}


resource "aws_subnet" "subnet_bastion" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "20.0.1.0/24"
    availability_zone       = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true # 공인 ip 할당
    tags                    = { Name = "tmp_bastion" }
}

resource "aws_subnet" "subnet_was" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "20.0.10.0/24"
    availability_zone       = data.aws_availability_zones.available.names[0]
    tags                    = { Name = "tmp_was" }
  
}

resource "aws_subnet" "subnet_db" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "20.0.30.0/24"
    availability_zone       = data.aws_availability_zones.available.names[0]
    tags                    = { Name = "tmp_db" }
  
}

resource "aws_subnet" "subnet_mgmt" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "20.0.50.0/24"
    availability_zone       = data.aws_availability_zones.available.names[0]
    tags                    = { Name = "tmp_mgmt" }
  
}
# 보안그룹 생성 =================================================================
resource "aws_security_group" "tmp_alb_sg" {
    name = "tmp_alb_sg"
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
    }

    ingress {
        from_port           = 443
        to_port             = 443
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
    }
    egress {
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         =   ["20.0.10.0/24"]
    }
}
resource "aws_security_group" "tmp_bastion_sg" {
    ingress {
        from_port           = 22
        to_port             = 22
        protocol = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]     # 본인 ip ssh접속용
    }
}
resource "aws_security_group" "tmp_mgmt_sg" {
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0"]
    }
  
}
#인터넷 게이트웨이 생성 ===============================================================
resource "aws_internet_gateway" "tmp_igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {Name = "tmp_igw"}
}
# public subnet 라우팅 테이블 연결 ====================================================
resource "aws_route_table" "tmp_rt" {
    # 어떤 vpc 의 소속인지 설정
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tmp_igw.id
    }
}

