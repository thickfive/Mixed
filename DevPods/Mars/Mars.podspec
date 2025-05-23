#
# Be sure to run `pod lib lint Mars.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Mars'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Mars.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/thickfive/Mars'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'thickfive' => 'thickfive@live.com' }
  s.source           = { :git => 'https://github.com/thickfive/Mars.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'mars.framework/Headers/**/*.h'
  s.public_header_files = 'mars.framework/Headers/Mars.h'
  s.vendored_frameworks = 'mars.framework'
  s.frameworks = 'SystemConfiguration', 'Foundation', 'CoreTelephony'
  s.libraries = 'stdc++', 'stdc++', 'z'
  s.static_framework = true
end
