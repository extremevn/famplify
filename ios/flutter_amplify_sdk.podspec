#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_amplify_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_amplify_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin aws cognito and api'
  s.description      = <<-DESC
Flutter plugin aws cognito and api
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Amplify', '1.0.6'
  s.dependency 'AmplifyPlugins/AWSAPIPlugin'
  s.dependency 'AmplifyPlugins/AWSCognitoAuthPlugin'
  
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
