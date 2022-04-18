source 'https://github.com/CocoaPods/Specs.git'
workspace 'RudderAppsFlyer.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'

def shared_pods
    pod 'RudderStack', :path => '~/Documents/Rudder/RudderStack-Swift/'
end

target 'RudderAppsFlyer' do
    project 'RudderAppsFlyer.xcodeproj'
    shared_pods
    pod 'AppsFlyerFramework', '6.5.4'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    shared_pods
    pod 'RudderAppsFlyer', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    shared_pods
    pod 'RudderAppsFlyer', :path => '.'
end
