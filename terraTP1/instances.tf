resource "aws_key_pair" "tp1_key" {
  key_name   = "tp1-keypair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "local_file" "cluster_keypair" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.module}/tp1-keypair.pem"
}

resource "aws_instance" "pokedex_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.http_access.id, aws_security_group.ssh_access.id]

  key_name = aws_key_pair.tp1_key.key_name

  tags = {
    Name = "pokedex-instance"
  }

  user_data = file("${path.module}/user-data.sh")

}

resource "aws_instance" "ssh_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public_subnets[1].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]

  key_name = aws_key_pair.tp1_key.key_name

  tags = {
    Name = "ssh-instance"
  }
}