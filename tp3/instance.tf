/*
* SSH key
*/
resource "aws_key_pair" "tp3_key" {
  key_name   = "tp3-keypair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "local_file" "cluster_keypair" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.module}/tp3-keypair.pem"
}

/*
* Instance EC2
*/
resource "aws_instance" "tp3-2484435-multi-service" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tp3-2484435-sg.id]

  key_name = aws_key_pair.tp3_key.key_name

  tags = {
    Name = "tp3-2484435-multi-service"
  }

  user_data = file("${path.module}/user-data.sh")

}