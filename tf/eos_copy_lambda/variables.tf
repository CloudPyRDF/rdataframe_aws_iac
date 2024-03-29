# variable "pkg_filename" {}
variable "lambda_name" {}
variable "handler" {
  default = "lambda.lambda_handler"
}
variable "memory_size" {}
variable "timeout" {}

# variable "tags" {
#   type = map
# }

variable "run" {
  default = false
}

variable "input_bucket" {}
variable "eos_login" {}
variable "eos_password" {}
variable "eos_default_path" {}
