source 'https://github.com/CocoaPods/Specs.git'
workspace 'RudderAppsFlyer.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'

target 'RudderAppsFlyer' do
    project 'RudderAppsFlyer.xcodeproj'
    pod 'Rudder'
    pod 'AppsFlyerFramework'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    pod 'RudderAppsFlyer', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    pod 'RudderAppsFlyer', :path => '.'
end
