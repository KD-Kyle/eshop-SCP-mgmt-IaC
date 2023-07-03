output "vpc_id" {
    value = scp_vpc.mgmt_vpc.id
}

output "public_subnet_id" {
    value = [scp_subnet.public.id] 
}

output "private_subnet_id" {
    value = [scp_subnet.private.id] 
}

output "bastion_nat_ip" {
    value = scp_virtual_server.bastion.nat_ipv4
}

output "admin_ip" {
    value = scp_virtual_server.admin.ipv4
}

output "region" {
    value =  var.region
}