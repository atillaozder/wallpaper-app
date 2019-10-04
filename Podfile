platform :ios, '10.0'
workspace 'Wallpapers.xcworkspace'

def unused_pods
  pod 'Alamofire', '~> 5.0.0-beta.5'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'SDWebImage', '~> 5.0'
  pod 'SideMenu', '~> 6.0'
end

def shared_pods
  pod 'Google-Mobile-Ads-SDK'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.13.4'
  pod 'CropViewController'
end

abstract_target 'Wallpapers' do
  use_frameworks!
  shared_pods

  target 'Core' do
    inherit! :search_paths
    project 'core/Core.xcodeproj'
    shared_pods
  end

  target 'MiniWorld' do
    inherit! :search_paths
    project 'mw/MiniWorld.xcodeproj'
    shared_pods
  end

  target 'LOL' do
    inherit! :search_paths
    project 'lol/LOL.xcodeproj'
    shared_pods
  end

  target 'CRoyale' do
    inherit! :search_paths
    project 'cr/CRoyale.xcodeproj'
    shared_pods
  end

  target 'Coc' do
    inherit! :search_paths
    project 'coc/Coc.xcodeproj'
    shared_pods
  end

  target 'Illustrator' do
    inherit! :search_paths
    project 'illustrator/Illustrator.xcodeproj'
    shared_pods
  end

  target 'LoveAlarm' do
    inherit! :search_paths
    project 'lovealarm/LoveAlarm.xcodeproj'
    shared_pods
  end

  target 'Spiderman' do
    inherit! :search_paths
    project 'spiderman/Spiderman.xcodeproj'
    shared_pods
  end

  target 'GachaGL' do
    inherit! :search_paths
    project 'gachalife/GachaGL.xcodeproj'
    shared_pods
  end
end
  