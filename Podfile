platform :ios, '10.0'
source 'https://github.com/CocoaPods/Specs.git'
project 'ParaClient.xcodeproj'
use_frameworks!


def para_pods
    pod 'CryptoSwift', '1.0.0'
    pod 'SwiftyJSON', '5.0.0'
    pod 'Alamofire', '~> 5.0.0-beta.6'
end

target "ParaClient" do
    para_pods
end
target "ParaClientTests" do
    para_pods
end
