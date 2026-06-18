flutter create --no-pub --overwrite . \
               --project-name "flutter_rotation_sensor" \
               --description "A package provides a stream of device's orientation in three different representations: a rotation matrix, a quaternion, and Euler angles (azimuth, pitch, roll)." \
               --org "net.tlserver6y" \
               --template "plugin"

git checkout HEAD -- "./.gitignore"
git checkout HEAD -- "./CHANGELOG.md"
git checkout HEAD -- "./android/src/main/kotlin/net/tlserver6y/flutter_rotation_sensor/FlutterRotationSensorPlugin.kt"
git clean -fd        "./android/src/test/*"
git clean -fd        "./example/ios/RunnerTests/"
git clean -fd        "./example/integration_test/"
git checkout HEAD -- "./example/lib/*"
git clean -fd        "./example/lib/"
git checkout HEAD -- "./example/README.md"
git clean -fd        "./example/test/"
git checkout HEAD -- "./ios/flutter_rotation_sensor/Sources/flutter_rotation_sensor/FlutterRotationSensorPlugin.swift"
git checkout HEAD -- "./flutter_rotation_sensor.iml"
git checkout HEAD -- "./LICENSE"
git checkout HEAD -- "./lib/*"
git clean -fd        "./lib/"
git checkout HEAD -- "./README.md"
git checkout HEAD -- "./test/*"
git clean -fd        "./test/"
