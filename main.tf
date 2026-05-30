
#下記設定関係のため、変更禁止
#================================================================================================

terraform {
  backend "s3" {
    bucket = "tfstate-shimasan-20260529"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}


provider "aws" {
    region = "ap-northeast-1"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "my-vpc"
    }
}

resource  "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-shimasan-20260529"  # 名前は自由に
}


resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

#==================================================================================================

#サブネット追加
resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-1d"
    map_public_ip_on_launch = true
    tags = {
        Name = "my-subnet"
    }
}




