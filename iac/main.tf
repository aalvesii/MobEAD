provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "windows_sg" {
  name        = "windows_sg_mobead"
  description = "Liberar RDP, HTTP e WinRM"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "windows_2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

resource "aws_instance" "win_server" {
  ami             = data.aws_ami.windows_2019.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.windows_sg.name]
  key_name        = "chave-devops"

  user_data = <<-EOF
    <powershell>
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile ConfigureRemotingForAnsible.ps1
    powershell -ExecutionPolicy RemoteSigned .\ConfigureRemotingForAnsible.ps1 -CertValidityDays 3650 -EnableCredSSP
    </powershell>
  EOF

  tags = {
    Name = "MobEAD-Windows-Server"
  }
}

output "public_ip" {
  value = aws_instance.win_server.public_ip
}
