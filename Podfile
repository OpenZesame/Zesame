def shared_pods
	pod 'secp256k1'
  pod 'BigNumber'
end

target 'ZilliqaSDK-iOS' do
  platform :ios, '11.0'
  shared_pods
  
  target 'ZilliqaSDKTests-iOS' do
    inherit! :search_paths
  end
end

target 'ZilliqaSDK-macOS' do
  platform :osx, '10.13.4'
  shared_pods
  
  target 'ZilliqaSDKTests-macOS' do
    inherit! :search_paths
  end
end
