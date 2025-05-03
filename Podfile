# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end

target 'Mixed' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static
  # Debug
  pod 'LookinServer', :configurations => ['Debug']
  pod 'FLEX', :configurations => ['Debug']
  pod 'CocoaLumberjack/Swift'
#  pod 'PLCrashReporter'
  pod 'KSCrash', '~> 2.0.0'
  
  # DevPods
  pod 'LibExample', :path => 'DevPods/LibExample'
  pod 'AsyncDisplayKit', :path => 'DevPods/AsyncDisplayKit'
  pod 'IJKPlayer', :path => 'DevPods/IJKPlayer'
  pod 'IJKMediaFramework', :path => 'DevPods/IJKMediaFramework'
  pod 'XXLog', '~> 0.2.0'
#  pod 'Mars', :path => 'DevPods/Mars' # 需要设置 C++ and Objcetive-C Interoperability 为 C++ / Objcetive-C++, 会与 C / Objcetive-C 冲突, 不要轻易使用

  # Pods
#  pod 'Masonry'
  pod 'HandyJSON'
  pod 'SnapKit'
  pod 'Moya'
  pod 'Hero'            # Hero
  pod 'CollectionKit'   # Hero
  pod 'KTVHTTPCache', '~> 3.0.0'
  pod 'SwiftCubicSpline'
#  pod 'YYCache'
end

target 'Keyboard' do
  use_frameworks! :linkage => :static
  pod 'SnapKit'
end

