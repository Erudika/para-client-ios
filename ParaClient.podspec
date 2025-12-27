Pod::Spec.new do |s|
  s.name         = "ParaClient"
  s.version = "1.33.0"
  s.summary      = "Para Client for iOS"
    s.description  = "Para is a simple, modular backend framework for object persistence and retrieval. It helps you build applications faster by taking care of the backend. This is the Swift client for Para."
  s.homepage     = "https://github.com/erudika/para-client-ios"
  s.documentation_url = "https://paraio.org/docs/index.html"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author       = { "Alex Bogdanovski" => "alex@erudika.com" }
  s.social_media_url = "https://twitter.com/para_io"
  s.cocoapods_version = ">= 1.0"

  s.ios.deployment_target = "15.0"
  s.macos.deployment_target = "14.0"
  s.watchos.deployment_target = "8.0"
  s.tvos.deployment_target = "17.0"

  s.swift_versions = ["6.0"]
  s.source       = { :git => "https://github.com/erudika/para-client-ios.git", :tag => "#{s.version}" }
  s.source_files = "Source/*.{h,swift}", "Sources/*.{h,swift}"
  s.requires_arc = true

  s.dependency "CryptoSwift", "~> 1.9"
  s.dependency "Alamofire", "~> 5.11"
end
