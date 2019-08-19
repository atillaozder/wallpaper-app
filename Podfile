platform :ios, '10.0'
workspace 'Wallpapers.xcworkspace'

def shared_pods
  pod 'Alamofire', '~> 5.0.0-beta.5'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'SDWebImage', '~> 5.0'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.13.4'
end

abstract_target 'Wallpapers' do
  use_frameworks!
  shared_pods

  target 'Core' do
    inherit! :search_paths
    project 'core/Core.xcodeproj'
    shared_pods
  end

  target 'Wallpapers for MW' do
    inherit! :search_paths
    project 'mw/Wallpapers for MW.xcodeproj'
    shared_pods
  end

  target 'Wallpapers for LOL' do
    inherit! :search_paths
    project 'lol/Wallpapers for LOL.xcodeproj'
    shared_pods
  end
end
  