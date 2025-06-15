#!/bin/bash

# Terraformのバージョンを取得
version_output=$(terraform version 2>&1)

# コマンドが成功しているか確認
if [ $? -ne 0 ]; then
  echo "Terraformコマンドが失敗しました。Terraformがインストールされているか確認してください。"
  exit 1
fi

# バージョンを抽出
version=$(echo "$version_output" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')

# バージョンがv1.12.1か確認
if [ "$version" == "v1.12.1" ]; then
  echo "Terraformのバージョンはv1.12.1です。"
else
  echo "Terraformのバージョンはv1.12.1ではありません。現在のバージョン: $version"
fi
