#replace the values as per setup configuration
nutanix_username = "admin"
nutanix_password = "nx2Tech254!"
nutanix_endpoint = "10.42.42.40"
nutanix_port = 9440

#replace this values as per the setup
subnet_name = "Primary"
cluster_name = "PHX-POC042"

#this variable will be used in adding disks to vm in main.tf
disk_sizes = [1024,1024,2048]