
terraform{
    required_providers {
        nutanix = {
            source = "nutanix/nutanix"
            version = "1.6.1"
        }
    }
}

#definig nutanix configuration
provider "nutanix"{
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  port = var.nutanix_port
  insecure = true
}

#pull existing image data (can upload image as well using nutanix_image resource)
data "nutanix_image" "centos"{
  image_name = "CentOS7.qcow2"
}

#pull desired cluster data
data "nutanix_cluster" "cluster"{
  name = var.cluster_name
}

#pull desired subnet data
data "nutanix_subnet" "subnet"{
  subnet_name = var.subnet_name
}

#create mysql virtual machine
resource "nutanix_virtual_machine" "mysql-vm-demo" {
  name = "cc-tf-mysql"
  cluster_uuid = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "1"
  num_sockets = "4"
  memory_size_mib = 4096

  #add basic disk with centos image
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = data.nutanix_image.centos.id
    }
  }

  #add nic
  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }

  #Testing local-exec, writes file to local machine
  provisioner "local-exec" {
    command = "echo export MYSQL_ENDPOINT=${self.nic_list[0].ip_endpoint_list[0].ip}:3306 >> vault/README.md"
   }

  connection {
    type     = "ssh"
    user     = "root"
    password = "nutanix/4u"
    host     = "${self.nic_list[0].ip_endpoint_list[0].ip}"
  }

  provisioner "file" {
    source = "mysql/install_mysql.sh"
    destination = "/tmp/install_mysql.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${self.nic_list[0].ip_endpoint_list[0].ip} >> ip.txt",
      "echo exclude=mirrors.raystedman.org >> /etc/yum/pluginconf.d/fastestmirror.conf",
      "chmod 777 /tmp/install_mysql.sh",
      "/tmp/install_mysql.sh",
    ]
  }
}

#create flask app virtual machine
resource "nutanix_virtual_machine" "flaskapp-vm-demo" {
  name = "cc-tf-flaskapp"

  depends_on = [nutanix_virtual_machine.mysql-vm-demo]

  cluster_uuid = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "1"
  num_sockets = "4"
  memory_size_mib = 4096

  #add basic disk with centos image
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = data.nutanix_image.centos.id
    }
  }

  #add nic
  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }

  #Testing local-exec, writes file to local machine
  provisioner "local-exec" {
    command = "echo ${self.nic_list[0].ip_endpoint_list[0].ip} >> flaskapp_ip.txt"
   }

  connection {
    type     = "ssh"
    user     = "root"
    password = "nutanix/4u"
    host     = "${self.nic_list[0].ip_endpoint_list[0].ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /root/flaskapp",
      "echo exclude=mirrors.raystedman.org >> /etc/yum/pluginconf.d/fastestmirror.conf",
    ]
  }

  provisioner "file" {
    source = "flaskapp/"
    destination = "/root/flaskapp"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${self.nic_list[0].ip_endpoint_list[0].ip} >> ip.txt",
      "echo mysql_host: ${nutanix_virtual_machine.mysql-vm-demo.nic_list[0].ip_endpoint_list[0].ip} >> /root/flaskapp/db.yaml",
      "chmod 777 /root/flaskapp/install_flask.sh",
      "/root/flaskapp/install_flask.sh",
    ]
  }
}

output "mysql_name" {
  value = nutanix_virtual_machine.mysql-vm-demo.name
}

output "mysql_ip" {
  value = nutanix_virtual_machine.mysql-vm-demo.nic_list[0].ip_endpoint_list[0].ip
}

output "flaskapp_name" {
  value = nutanix_virtual_machine.flaskapp-vm-demo.name
}

output "flaskapp_ip" {
  value = nutanix_virtual_machine.flaskapp-vm-demo.nic_list[0].ip_endpoint_list[0].ip
}
