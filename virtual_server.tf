data "scp_standard_image" "ubuntu_image_vm" {
    service_group = "COMPUTE"
    service       = "Virtual Server"
    region        = var.region
    filter {
        name = "image_name"
        values = ["Ubuntu 20.04"]
        use_regex = true
    }
}
resource "scp_virtual_server" "bastion" {
    //name_prefix         = "eshopbastion"   # will be rolled back after v1.8.6
    //timezone            = "Asia/Seoul"     # will be rolled back after v1.8.6
    virtual_server_name = "eshopbastion"     # will be deleted after v1.8.6
    admin_account       = "root"
    admin_password      = var.bastion_password
    cpu_count           = 1
    memory_size_gb      = 2
    image_id            = data.scp_standard_image.ubuntu_image_vm.id
    vpc_id              = scp_vpc.mgmt_vpc.id
    subnet_id           = scp_subnet.public.id

    delete_protection   = false
    contract_discount   = "None"

    os_storage_name     = "eshopBtDisk1"
    os_storage_size_gb  = 100
    os_storage_encrypted = false

    #initial_script_content = "/test"
    public_ip_id        = scp_public_ip.bastion_ip.id
    security_group_ids  = [
        scp_security_group.bastion_sg.id 
    ]
    use_dns = true
    state = "RUNNING"
    //availability_zone_name = "AZ1" 
}

resource "scp_public_ip" "bastion_ip" {
    description = "Public IP generated from Terraform"
    region      = var.region
}

resource "scp_virtual_server" "admin" {
    //name_prefix         = "eshopadmin"   # will be rolled back after v1.8.6 
    //timezone            = "Asia/Seoul"   # will be rolled back after v1.8.6
    virtual_server_name = "eshopadmin"     # will be deleted after v1.8.6 
    admin_account       = "root"
    admin_password      = var.admin_password
    cpu_count           = 2
    memory_size_gb      = 4
    image_id            = data.scp_standard_image.ubuntu_image_vm.id
    vpc_id              = scp_vpc.mgmt_vpc.id
    subnet_id           = scp_subnet.private.id

    delete_protection   = false
    contract_discount   = "None"

    os_storage_name     = "eshopAdDisk1"
    os_storage_size_gb  = 100
    os_storage_encrypted = false

    initial_script_content = <<EOF
# kubectl 설치
snap install kubectl --classic
kubectl version --client
# alias 설정
echo 'alias cls=clear' >> /home/ubuntu/.bashrc
echo 'export PATH=$PATH:/home/ubuntu/bin' >> /home/ubuntu/.bashrc
echo 'source <(kubectl completion bash)' >> /home/ubuntu/.bashrc
echo 'alias k=kubectl' >> /home/ubuntu/.bashrc
echo 'complete -F __start_kubectl k' >> /home/ubuntu/.bashrc    
# alias 추가
echo 'alias mc="kubectl config use-context mgmt"' >> /home/ubuntu/.bashrc
echo 'alias ec="kubectl config use-context eshop"' >> /home/ubuntu/.bashrc
# WhereAmI
echo 'alias wai="kubectl config get-contexts"' >> /home/ubuntu/.bashrc
# ubuntu sudoers 추가
sudo echo 'ubuntu ALL=NOPASSWD:ALL' >> /etc/sudoers
EOF

    security_group_ids = [
        scp_security_group.admin_sg.id 
    ]
    use_dns = true
    state = "RUNNING"
    //availability_zone_name = "AZ1" 
/*
    external_storage {
        name            = eshopExtStorage
        product_name    = "SSD"
        storage_size_gb = 10
        encrypted       = false
    }
*/
}
