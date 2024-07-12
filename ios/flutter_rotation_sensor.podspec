#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_rotation_sensor.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_rotation_sensor'
  s.version          = '0.0.1'
  s.summary          = <<-DESC
A package provides a stream of device's orientation in three different representations: a rotation
matrix, a quaternion, and Euler angles (azimuth, pitch, roll).
                       DESC
  s.description      = <<-DESC
A package provides a stream of device's orientation in three different representations: a rotation
matrix, a quaternion, and Euler angles (azimuth, pitch, roll).
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
  s.swift_version = '5.0'
end
