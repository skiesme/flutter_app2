#! /bin/sh

uKey=9812388432113be529db985e3ba38224
_api_key=7985c2827257ea59c9559e929a880dd9

echo "build android ...."

flutter build apk --release -t lib/main_publish.dart

pwd=`pwd`

apk_release_file=${pwd}/build/app/outputs/apk/release/app-release.apk

echo "开始上传 ${apk_release_file} 到蒲公英...."
curl -F "file=@${apk_release_file}" -F "_api_key=${_api_key}" https://www.pgyer.com/apiv2/app/upload

echo "\n android done"