variable "aws_region" {
  default = "us-east-1"
}

variable "source_ami" {
  default = "ami-0ec18210d8dacc4ff"
}

variable "instance_type" {
  default = "t4g.2xlarge"
}

variable "ssh_username" {
  default = "ubuntu"
}

source "amazon-ebs" "ubuntu" {
  ami_name                = "dexi_ubuntu_22_powerful"
  ami_description         = "Ubuntu 22.04.4 ARM64 AMI created from Raspberry Pi image"
  instance_type           = var.instance_type
  region                  = var.aws_region
  source_ami              = var.source_ami
  ssh_username            = var.ssh_username

  # Block Device Mapping for Root Volume
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 300
    volume_type           = "io1"
    iops                  = 3000
    delete_on_termination = true
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  # Copy the resources directory
  provisioner "file" {
    source      = "resources"
    destination = "/tmp/"
  }

  # Execute the provision script
  provisioner "shell" {
    script          = "resources/provision.sh"
    execute_command = "sudo bash '{{ .Path }}'"
  }
}
