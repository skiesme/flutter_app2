buildFramework() {
    echo "===生成App.framework和flutter_assets==="
    flutter build ios --release
}

buildAAR() {
    echo "===生成AAR==="
    cd ./android
    ./gradlew assembleRelease

    cd ../
}

clean() {
    echo "===清理flutter历史编译==="
    flutter clean

    echo "===重新生成plugin索引==="
    flutter packages get
}

if [ "$1" = "ios" ]; 
then
    clean

    buildFramework
else
    clean

    buildAAR
fi