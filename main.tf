provider "aws" {
    region = "ap-northeast-2"
}
resource "aws_vpc" "vpc_1" {
    cidr_block = "20.0.0.0/16"
    enable_dns_hostnames = true # 인스턴스에 dns 이름을 부여 하기 위해 활성화
    enable_dns_support = true
    tags = {
      Name = "self-practice-vpc1"
    }
}
