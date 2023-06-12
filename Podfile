source 'https://github.com/CocoaPods/Specs.git'
workspace 'RudderAppsFlyer.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'

target 'RudderAppsFlyer' do
    project 'RudderAppsFlyer.xcodeproj'
    pod 'Rudder', '~> 2.0'
    pod 'AppsFlyerFramework', '6.5.4'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    pod 'RudderAppsFlyer', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    pod 'RudderAppsFlyer', :path => '.'
end
