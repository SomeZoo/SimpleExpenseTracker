platform :ios, '15.0'

target 'SimpleExpenseTracker' do
  use_frameworks!

  # 网络请求库
  pod 'AFNetworking', '~> 4.0'
  
  # 自动布局库
  pod 'Masonry', '~> 1.1'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end

end

