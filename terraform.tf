provider "aws" {
  region = "us-east-1"
}

resource "aws_spot_instance_request" "cheap_worker" {
  count                  = length(var.components)
  ami                    = data.aws_ami.ami.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-03a6af6735757ed3e"]
  wait_for_fulfillment   = true
  tags = {
    Name = element(var.components, count.index)
  }
}

resource "aws_ec2_tag" "tags" {
  count       = length(var.components)
  resource_id = element(aws_spot_instance_request.cheap_worker.*.spot_instance_id, count.index)
  key         = "Name"
  value       = element(var.components, count.index)
}

resource "null_resource" "file" {
  triggers = {
    abc = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
echo 127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 > /tmp/hosts
EOF
  }
}

resource "null_resource" "hosts" {
  count = length(var.components)
  depends_on = [null_resource.file]
  triggers = {
    abc = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
echo ${element(aws_spot_instance_request.cheap_worker.*.private_ip, count.index)} ${element(var.components, count.index)} >>/tmp/hosts
EOF
  }
}

resource "null_resource" "hostname" {
  depends_on = [null_resource.hosts]
  count = length(var.components)
  triggers = {
    abc = timestamp()
  }
  provisioner "remote-exec" {
    connection {
      host = element(aws_spot_instance_request.cheap_worker.*.public_ip, count.index)
      user = "root"
      password = "DevOps321"
    }
    inline = [
      "set-hostname -skip-apply ${element(var.components, count.index)}"
    ]
  }
  provisioner "file" {
    connection {
      host = element(aws_spot_instance_request.cheap_worker.*.public_ip, count.index)
      user = "root"
      password = "DevOps321"
    }
    source      = "/tmp/hosts"
    destination = "/etc/hosts"
  }
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "^Cent*"
  owners      = ["973714476881"]
}

variable "components" {
  default = [ "rabbitmq", "eureka", "searching" ]
  #default = [ "rabbitmq", "postgres", "eureka", "search-service", "booking", "frontend", "zipkin" ]
}


locals {
  instance_addrs = zipmap(var.components,aws_spot_instance_request.cheap_worker.*.public_ip)
}

output "public_ip" {
  value = local.instance_addrs
}