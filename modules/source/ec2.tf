resource "aws_instance" "ec2_data_generator" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.subnet_source_a.id
  vpc_security_group_ids      = [aws_security_group.allow_public_source.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name    = "ec2_data_generator"
    project = "oracle2aurora"
  }
}

resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = file("${var.key_path}.pub")
}
