data aws_ami ubuntu {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource aws_instance app {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # Hard code subnet just to get an example working
  subnet_id = aws_subnet.this["${var.environment} EC2 Subnet - us-east-1a"].id

  tags = {
    Name        = "To-do List",
    Environment = var.environment
  }

  depends_on = [aws_subnet.this]
}