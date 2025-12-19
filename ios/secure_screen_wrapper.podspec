#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint secure_screen_wrapper.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'secure_screen_wrapper'
  s.version          = '1.0.1'
  s.summary          = 'A Flutter plugin to prevent screenshots'
  s.description      = <<-DESC
A Flutter plugin that prevents screenshots on Android, iOS, and Web.
Android: Blocks screenshots completely using FLAG_SECURE.
iOS: Makes screenshots appear black using secure text entry.
Web: Disables right-click, text selection, and screenshot shortcuts.
                       DESC
  s.homepage         = 'https://github.com/MShaheer2002/secure_screen_wrapper'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Muhammad Shaheer' => 'm.shaheershahid12@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
