#
# Be sure to run `pod lib lint IJKMediaFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IJKMediaFramework'
  s.version          = '0.1.0'
  s.summary          = 'A short description of IJKMediaFramework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/thickfive/IJKMediaFramework'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'thickfive' => 'thickfive@live.com' }
  s.source           = { :git => 'https://github.com/thickfive/IJKMediaFramework.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  
  s.source_files = 'IJKMediaFramework.framework/Headers/*.h'
  s.public_header_files = 'IJKMediaFramework.framework/Headers/*.h'
  s.vendored_frameworks = 'IJKMediaFramework.framework'
  s.frameworks = 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'MediaPlayer', 'MobileCoreServices', 'OpenGLES', 'QuartzCore', 'UIKit', 'VideoToolbox'
  s.libraries = 'z', 'bz2','stdc++'
  s.static_framework = true
end
