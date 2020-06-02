variable "default_route_table" {
  type        = string
  default     = ""
  description = "The route table to create a pairing connection with this VPC."
}

variable "default_vpc" {
  type        = string
  default     = ""
  description = "The VPC to create a pairing connection with this VPC."
}

variable "peer_to_default" {
  default     = true
  description = "Whether to create a peering connection to the default VPC."
}

variable "vpc_name" {
  type        = string
  description = "The name to give the VPC being created."
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block to assign the newly created VPC."
}

variable "env" {
  type        = string
  description = "The name environment the created VPC will be part of. Valid values are 'production', 'preview', 'staging', and 'shared'."
}

variable "owner" {
  type        = string
  description = "The name of the project or team that owns the VPC."
}

variable "end_date" {
  type        = string
  description = "The expected expiry date for the VPC. Use ISO-8601 formatted dates or '-' if an end date doesn't apply."
}

variable "project" {
  type        = string
  description = "The name or ID of the project the VPC is part of."
}

variable "deployment_type" {
  type        = string
  default     = "vm"
  description = "The deployment type the resources brought up by this module are part of."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones the VPC should be part of."
}

variable "map_public_ip_on_launch" {
  default     = false
  description = "Whether to map public IP addresses on-launch to resources in this VPC."
}

variable "cidr_new_bits" {
  default     = 8
  type        = number
  description = "The number of bits to extend the VPC CIDR block for each of the subnets."
}
