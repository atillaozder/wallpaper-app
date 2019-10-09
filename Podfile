platform :ios, '10.0'
workspace 'Wallpapers.xcworkspace'

def shared_pods
  pod 'Google-Mobile-Ads-SDK'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.13.4'
  pod 'CropViewController'
  pod 'FMPhotoPicker', '~> 0.8'
end

abstract_target 'Wallpapers' do
  use_frameworks!
  shared_pods

  target 'Core' do
    inherit! :search_paths
    project 'core/Core.xcodeproj'
    shared_pods
  end

  target 'GachaGL' do
    inherit! :search_paths
    project 'gachalife/GachaGL.xcodeproj'
    shared_pods
  end
end
  
