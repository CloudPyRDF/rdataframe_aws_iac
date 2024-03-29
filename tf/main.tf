resource "null_resource" "prepare_lambda_sources" {
  provisioner "local-exec" {
    command = "./build.sh"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf pkg"
  }
}


module "eos" {
  source = "./eos_copy_lambda"
  # pkg_filename     = var.eos_lambda_pkg_filename
  lambda_name      = var.eos_lambda_name
  memory_size      = var.eos_lambda_memory_size
  timeout          = var.eos_lambda_timeout
  eos_login        = var.eos_login
  eos_password     = var.eos_password
  eos_default_path = var.eos_default_path
  input_bucket     = aws_s3_bucket.input_bucket

  # run = var.run_eos

  depends_on = [null_resource.prepare_lambda_sources]
}

module "init" {
  source      = "./root_lambda"
  lambda_name = var.init_lambda_name
  memory_size = var.init_lambda_memory_size
  timeout     = var.init_lambda_timeout

  lambda_subnet = aws_subnet.efs_root.id
  lambda_sg     = aws_security_group.default.id
  input_bucket  = aws_s3_bucket.input_bucket
  efs           = aws_efs_access_point.access_point_for_lambda

  run = var.run_init_root

  depends_on = [module.eos]
}

module "root" {
  source      = "./root_lambda"
  lambda_name = var.root_lambda_name
  memory_size = var.root_lambda_memory_size
  timeout     = var.root_lambda_timeout

  lambda_subnet = aws_subnet.efs_root.id
  lambda_sg     = aws_security_group.default.id
  input_bucket  = aws_s3_bucket.processing_bucket
  efs           = aws_efs_access_point.access_point_for_lambda

  # run = var.run_init_root

  depends_on = [
    module.init,
    aws_vpc_endpoint_route_table_association.route_table_association,
    aws_route_table_association.assoc,
    aws_route_table_association.assoc_pub,
    aws_route.primary_internet_access
  ]
}

# module "reduce_lambda" {
#   source      = "./root_lambda"
#   lambda_name = var.reduce_lambda_name

#   lambda_subnet = aws_subnet.efs_root.id
#   lambda_sg     = aws_security_group.default.id
#   input_bucket  = aws_s3_bucket.processing_bucket
#   efs           = aws_efs_access_point.access_point_for_lambda

#   # run = var.run_init_root

#   depends_on = [module.init_root_lambda]
# }