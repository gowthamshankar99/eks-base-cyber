variable "instance_name" {
  default = "dr"
  type = string
}

variable "aws_region" {
  default = "us-east-1"
  type = string
}

variable "aws_account_id" {
  type = string
  default = "724421275000"
  validation {
    condition     = length(var.aws_account_id) == 12 && can(regex("^\\d{12}$", var.aws_account_id))
    error_message = "Invalid AWS account ID"
  }
}

variable "aws_assume_role" { 
    type = string 
    default = "DREKSRole"
}