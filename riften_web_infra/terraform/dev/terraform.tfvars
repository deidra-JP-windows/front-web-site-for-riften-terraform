# メンテナンスページや開発段階で使用　公開時は0.0.0.0/32
ip_set_cloudfront_waf = ["0.0.0.0/32"]

# Lambda Function URL (APIバックエンド)
lambda_backend_url = "example-xxxxxxxx.lambda-url.ap-northeast-1.on.aws"


# Lambda@Edge認証Lambda ZIPファイルパス（us-east-1でビルドしたZIPファイルを指定）
auth_lambda_zip_path = "./lambda/auth/auth_lambda.zip"
# Lambda@Edge認証LambdaのIAMロールARN（us-east-1で作成したロールARNを指定）
auth_lambda_role_arn = "arn:aws:iam::123456789012:role/lambda-edge-role"
# 認証トークン値（本番は安全な値に変更）
auth_token = "dummy-token"
