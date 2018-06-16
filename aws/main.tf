provider "aws" {
  region                  = "eu-west-3"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "polaris-tom"
}
resource "aws_instance" "web" {
  ami = "ami-0e55e373"
  instance_type = "t1.micro"
  tags {
  Name = "ttest"
  }
}
