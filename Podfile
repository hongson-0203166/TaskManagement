# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ToDoList' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ToDoList
  pod 'SwiftHEXColors'
  pod 'SnapKit'
  pod 'FirebaseAnalytics'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'ReachabilitySwift'
  pod 'Alamofire'
  pod 'FirebaseStorage'
  pod 'Kingfisher'
  pod 'GoogleSignIn'
  pod 'JWTDecode'
end
post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
