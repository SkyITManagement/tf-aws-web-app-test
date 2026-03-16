data "terraform_remote_state" "rds" {
  backend = "local"
  config = {
    path = var.rds_terraform_state_path
  }
}

# Use default VPC and subnet to keep this simple.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "webapp" {
  name        = "webapp-sg"
  description = "Allow HTTP and SSH to web app instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webapp" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.webapp_instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.webapp.id]
  associate_public_ip_address = true
  key_name = var.webapp_ssh_key_name != "" ? var.webapp_ssh_key_name : null

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              cat > /var/www/html/index.html <<EOD
              <html>
                <body>
                  <h1>Simple Web App</h1>
                  <p>RDS endpoint: ${data.terraform_remote_state.rds.outputs.db_endpoint}</p>
                  <p>RDS port: ${data.terraform_remote_state.rds.outputs.db_port}</p>
                </body>
              </html>
              EOD
              EOF

  tags = {
    Name = "webapp-instance"
  }
}

resource "aws_eip" "webapp_ip" {
  instance = aws_instance.webapp.id
}
