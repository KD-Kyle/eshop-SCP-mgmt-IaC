data "http" "get_my_public_ip" {
  url = "https://ifconfig.me"
}

data "scp_region" "region" {}

resource "scp_security_group" "bastion_sg" {
  vpc_id       = scp_vpc.mgmt_vpc.id
  name         = "eshopMgmtBtSG"
  description  = "eshop management bastion server security group"
}

resource "scp_security_group" "admin_sg" {
  vpc_id       = scp_vpc.mgmt_vpc.id
  name         = "eshopMgmtAdSG"
  description  = "eshop management admin server security group"
}

resource "scp_security_group" "mgmt_cluster_sg" {
  vpc_id       = scp_vpc.mgmt_vpc.id
  name         = "eshopMgmtClSG"
  description  = "eshop management admin server security group"
}


resource "scp_security_group_rule" "admin_rule_tcp" {
    security_group_id = scp_security_group.admin_sg.id 
    direction         = "in"
    description       = "ssh SG rule generated from Terraform"
    addresses_ipv4 = ["10.0.10.0/24"]
    service { type = "all" }
}

resource "scp_security_group_rule" "admin_rule_all" {
    security_group_id = scp_security_group.admin_sg.id 
    direction         = "out"
    description       = "SG out rule generated from Terraform"
    addresses_ipv4 = ["0.0.0.0/0"]
    service { type = "all" }
}

resource "scp_security_group_rule" "bastion_rule_all" {
    security_group_id = scp_security_group.bastion_sg.id 
    direction         = "out"
    description       = "SG out rule generated from Terraform"
    addresses_ipv4 = ["0.0.0.0/0"]
    service { type = "all" }
}

resource "scp_security_group_rule" "mgmt_cluster_rule_all" {
    security_group_id = scp_security_group.mgmt_cluster_sg.id 
    direction         = "out"
    description       = "SG out rule generated from Terraform"
    addresses_ipv4 = ["0.0.0.0/0"]
    service { type = "all" }
}

resource "scp_security_group_rule" "bastion_rule_tcp" {
    security_group_id = scp_security_group.bastion_sg.id 
    direction         = "in"
    description       = "TCP SG rule generated from Terraform"
    addresses_ipv4 = ["0.0.0.0/0"]
    service { 
        type = "tcp" 
        value = 80
    }
}
resource "scp_security_group_rule" "bastion_rule_ssh" {
    security_group_id = scp_security_group.bastion_sg.id 
    direction         = "in"
    description       = "SSH SG rule generated from Terraform"
    addresses_ipv4 = [
                        "${chomp(data.http.get_my_public_ip.body)}/32"
                     ]
    service { 
        type = "tcp" 
        value = 22
    }
}

### argo rollout 을 위해 추가되는 부분 ######
resource "scp_security_group_rule" "bastion-argo-rollout" {
    security_group_id = scp_security_group.bastion_sg.id 
    direction         = "in"
    description       = "TCP argo rollout SG rule generated from Terraform"
    addresses_ipv4 = [
                        "${chomp(data.http.get_my_public_ip.body)}/32"
                     ]
    service { 
        type = "tcp" 
        value = 3100
    }
}
############

### VPC Peering 을 위해 추가되는 부분 ######
resource "scp_security_group_rule" "admin_rule_peering" {
    security_group_id = scp_security_group.admin_sg.id 
    direction         = "in"
    description       = "ssh SG rule generated from Terraform"
    addresses_ipv4 = ["192.168.0.0/24"]
    service { 
        type = "tcp" 
        value = 22
    }
}
############
