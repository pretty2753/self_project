terraform {
  required_version = "~>1.14.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}

provider "aws" {
    region = "ap-northeast-2"
}
resource "aws_vpc" "main_vpc" {
    cidr_block              = "20.0.0.0/16"
    enable_dns_hostnames    = true # 인스턴스에 dns 이름을 부여 하기 위해 활성화
    enable_dns_support      = true
    tags = {
        Name                = "self-practice-vpc1"
    }
}

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
