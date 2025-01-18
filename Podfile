workspace 'AffordIQ'

target 'AffordIQ' do
  use_frameworks!
  platform :ios, '13.0'
  pod 'IQKeyboardManagerSwift'
  pod 'Siren'
  project 'AffordIQ/AffordIQ.xcodeproj'
end

target 'AffordIQUI' do
  use_frameworks!
  platform :ios, '13.0'
  pod 'Down', :inhibit_warnings => true
  pod 'SDWebImage'
  pod 'SDWebImageSVGCoder'
  pod 'NVActivityIndicatorView'
  pod 'LicensesViewController', '~> 0.10.0'
  project 'AffordIQ/AffordIQ.xcodeproj'
end

target 'AffordIQControls' do
  use_frameworks!
  platform :ios, '13.0'
  pod 'SDWebImage'
  pod 'SDWebImageSVGCoder'
  project 'AffordIQ/AffordIQ.xcodeproj'
end

target 'AffordIQAuth0' do
  use_frameworks!
  platform :ios, '13.0'
  pod 'Auth0', '~> 2.3', :inhibit_warnings => true
  project 'AffordIQ/AffordIQ.xcodeproj'
end

target 'AffordIQNetworkKit' do
  use_frameworks!
  platform :ios, '13.0'
  project 'AffordIQ/AffordIQ.xcodeproj'
end

target 'AffordIQFoundation' do
  use_frameworks!
  platform :ios, '13.0'
  project 'AffordIQ/AffordIQ.xcodeproj'
end

pod 'FirebaseAnalytics'
pod 'FirebaseCrashlytics'
pod 'FirebaseMessaging'
pod 'Firebase/InAppMessaging'
pod 'Firebase/RemoteConfig'
pod 'Firebase/Database'
pod 'Amplitude'
pod 'Wormholy', :configurations => ['DEBUG', 'DEMO']

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["DEVELOPMENT_TEAM"] = "4585569D5V"
      end
    end
  end
end
