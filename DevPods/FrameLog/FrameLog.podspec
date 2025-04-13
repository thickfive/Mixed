#
# Be sure to run `pod lib lint FrameLog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FrameLog'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FrameLog.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wutiaorong/FrameLog'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wutiaorong' => 'wutiaorong@bigo.sg' }
  s.source           = { :git => 'https://github.com/wutiaorong/FrameLog.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'

#  s.source_files = 'FrameLog/Module/**/*'
#  s.frameworks = 'SystemConfiguration', 'Foundation', 'CoreTelephony'
#  s.vendored_frameworks = 'FrameLog/Frameworks/mars.framework'
#  s.libraries = 'c++', 'z'

  s.source_files = 'FrameLog/Frameworks/mars.framework/Headers/*.h'
  s.public_header_files = 'FrameLog/Frameworks/mars.framework/Headers/*.h'
  s.frameworks = 'SystemConfiguration', 'Foundation', 'CoreTelephony'
  s.vendored_frameworks = 'FrameLog/Frameworks/mars.framework'
  s.libraries = 'c++', 'z'
  s.user_target_xcconfig =   {'OTHER_LDFLAGS' => ['-lc++']}
  
end
