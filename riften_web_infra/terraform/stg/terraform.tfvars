# メンテナンスページや開発段階で使用　公開時は0.0.0.0/32
ip_set_cloudfront_waf = ["0.0.0.0/32"]

# Lambda Function URL (APIバックエンド)
lambda_backend_url = "example-xxxxxxxx.lambda-url.ap-northeast-1.on.aws"

# Lambda@Edge認証LambdaのARN（バージョン付きARNを指定。未使用時は空文字）
# auth_lambda_edge_arn = "arn:aws:lambda:us-east-1:xxxxxxxxxxxx:function:auth-lambda:1"
