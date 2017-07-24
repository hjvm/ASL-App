# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'ASLApp' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ASLApp
	pod 'ChameleonFramework/Swift'
	pod 'EasyAnimation'
  target 'ASLAppTests' do
    inherit! :search_paths
    # Pods for testing

  end

  target 'ASLAppUITests' do
    inherit! :search_paths
    # Pods for testing
	
  end

pod 'SwiftTweaks', '~> 1.0'

# Enable DEBUG flag in Swift for SwiftTweaks
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'SwiftTweaks'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDEBUG'
                end
            end
        end
    end
end

end
