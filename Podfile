platform :ios, '15.0'
source 'https://github.com/CocoaPods/Specs.git'
project 'ParaClient.xcodeproj'
use_frameworks! :linkage => :static
inhibit_all_warnings!


def para_pods
    pod 'CryptoSwift', '~> 1.9'
    pod 'Alamofire', '~> 5.11'
end

target "ParaClient" do
    para_pods
end
target "ParaClientTests" do
    para_pods
end
