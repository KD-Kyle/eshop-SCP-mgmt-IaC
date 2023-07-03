variable "bastion_password" {
    default = "eshop123!"
    type = string
    description = "bastion server default password"
}

variable "admin_password" {
    default = "eshop123!"
    type = string
    description = "admin server default password"
}

variable "region" {
    default = "KR-WEST-2"
    type = string
    description = "region for management cluster"
}

