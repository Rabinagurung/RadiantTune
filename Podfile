# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'RadiantTune' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
	
  # audio player
  pod 'StreamingKit'
  
  # image
  pod 'Kingfisher'
  
  #hud
  pod 'SVProgressHUD'

  #Network Libraries
  pod 'Alamofire'
  pod 'Moya'
  
  # Pods for RadiantTune
  # Setting the same iOS deployment target for all pods as the project
  # to prevent errors, such as the one encountered previously.
    # otherwise I was getting following error
    #  SDK does not contain 'libarclite' at the path '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc/    # libarclite_iphonesimulator.a'; try increasing the minimum deployment target
   post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
end
