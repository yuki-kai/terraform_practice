resource "aws_instance" "example" {
  ami           = "ami-0c3fd0f5d33134a76"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform"
  }
}
