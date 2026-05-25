data "aws_ami" "server-ami" {

  owners = ["099720109477"]

  filter {
    name   = "image-id"
    values = ["ami-05cf1e9f73fbad2e2"]
  }
}

resource "aws_key_pair" "mtc_auth_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "client-server" {
  instance_type   = "m7i-flex.large"
  ami             = data.aws_ami.server-ami.id
  subnet_id       = aws_subnet.public-subnet[0].id
  security_groups = [aws_security_group.client-sg.id]
  key_name        = aws_key_pair.mtc_auth_key.id
  root_block_device {
    volume_size = var.volume_size
  }
  provisioner "local-exec" {
    command = "printf '\n${self.public_ip}' >> aws_hosts && aws ec2 wait instance-status-ok --instance-ids ${self.id} --region us-east-1"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '/^[0-9]/d' aws_hosts"
  }
  tags = {
    Name = "client-server"
  }
}

resource "null_resource" "grafana-install" {
  depends_on = [aws_instance.client-server]
  provisioner "local-exec" {
    command = <<EOT
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook \
-i aws_hosts \
--user ubuntu \
--private-key /home/ubuntu/.ssh/mtckey \
playbooks/main-playbook.yml
EOT
  }
}

