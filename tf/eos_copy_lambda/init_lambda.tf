data "aws_lambda_invocation" "get_sample_data" {
  count         = var.run ? 1 : 0
  function_name = aws_lambda_function.lambda.function_name

  input = <<JSON
{
  "eos_path": "${var.eos_default_path}",
  "eos_filename": "aws_root.zip",

  "eos_login": "${var.eos_login}",
  "eos_password": "${var.eos_password}",

  "s3_bucket_name": "${var.input_bucket}",
  "s3_object_key": "aws_root.zip"
}
JSON
}

output "result_entry" {
  value = var.run ? jsondecode(data.aws_lambda_invocation.get_sample_data[0].result) : null
}