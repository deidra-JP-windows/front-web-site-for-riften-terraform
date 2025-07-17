#!/bin/sh

# 引数が指定されていない場合はエラーメッセージを表示
if [ $# -eq 0 ]; then
  echo "使用法: $0 up | exec | down | rebuild"
  exit 1
fi

# up
if [ "$1" = "up" ]; then
  echo "コンテナを起動します..."
  MSYS_NO_PATHCONV=1 docker run -itd --name front-web-site-for-riften-terraform -v /c/Users/$USERNAME/.ssh:/root/.ssh front-web-site-for-riften-terraform
  MSYS_NO_PATHCONV=1 docker exec -it front-web-site-for-riften-terraform /bin/bash -c "
    chmod 600 /root/.ssh/config
    chmod 600 /root/.ssh/id_ed25519
    chown root:root /root/.ssh/config
    git clone git@github.com:deidra-JP-windows/front-web-site-for-riften-terraform.git
    cd /front-web-site-for-riften-terraform && exec /bin/bash
  "

# exec
elif [ "$1" = "exec" ]; then
  echo "コンテナに接続します..."
  MSYS_NO_PATHCONV=1 docker exec -it front-web-site-for-riften-terraform /bin/bash -c "cd /front-web-site-for-riften-terraform && exec /bin/bash"

# down
elif [ "$1" = "down" ]; then
  echo "コンテナを停止して削除します..."
  docker stop front-web-site-for-riften-terraform
  docker rm front-web-site-for-riften-terraform

# rebuild
elif [ "$1" = "rebuild" ]; then
  echo "イメージを再ビルドしてコンテナを再起動します..."
  docker stop front-web-site-for-riften-terraform
  docker rm front-web-site-for-riften-terraform
  docker build -t front-web-site-for-riften-terraform .
  MSYS_NO_PATHCONV=1 docker run -itd --name front-web-site-for-riften-terraform -v /c/Users/$USERNAME/.ssh:/root/.ssh front-web-site-for-riften-terraform
  MSYS_NO_PATHCONV=1 docker exec -it front-web-site-for-riften-terraform /bin/bash -c "
    chmod 600 /root/.ssh/config
    chmod 600 /root/.ssh/id_ed25519
    chown root:root /root/.ssh/config
    git clone git@github.com:deidra-JP-windows/front-web-site-for-riften-terraform.git
    cd /front-web-site-for-riften-terraform && exec /bin/bash
  "
else
  echo "不明なコマンド: $1"
  echo "使用法: $0 up | exec | down | rebuild"
  exit 1
fi
