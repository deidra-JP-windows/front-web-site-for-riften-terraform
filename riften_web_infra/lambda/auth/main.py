# Lambda@Edge 認証Lambda（CloudFrontリクエストイベント用）
# 環境変数にセットしたトークンとの突合せのみとなるため、結合テストでの動作確認を行い運用します。
import os


def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    headers = request.get('headers', {})

    # Lambda@Edgeではヘッダー名は小文字
    token_header = headers.get('authorization')
    valid_token = os.environ.get('AUTH_TOKEN', 'your-secret-token')

    if not token_header or token_header[0]['value'] != valid_token:
        # Lambda@Edgeの仕様に合わせてbodyEncoding, headersも返却
        return {
            'status': '403',
            'statusDescription': 'Forbidden',
            'body': '認証エラー: トークンが不正です',
            'bodyEncoding': 'text',
            'headers': {
                'content-type': [
                    {'key': 'Content-Type', 'value': 'text/plain; charset=utf-8'}
                ]
            },
        }

    # 認証OK: リクエストをそのまま転送
    return request
