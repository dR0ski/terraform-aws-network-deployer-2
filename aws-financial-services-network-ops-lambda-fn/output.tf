output "network-ops-lambda-fn-name" {
  value = aws_lambda_function.route53_association_lambda.function_name
}

output "network-ops-lambda-fn-arn" {
  value = aws_lambda_function.route53_association_lambda.arn
}

output "network-ops-lambda-fn-id" {
  value = aws_lambda_function.route53_association_lambda.id
}