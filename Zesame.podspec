Pod::Spec.new do |s|
    s.name         = 'Zesame'
    s.version      = '0.0.1'
    s.ios.deployment_target = "11.0"
    s.osx.deployment_target = "10.9"
    s.tvos.deployment_target = "9.0"
    s.watchos.deployment_target = "2.0"
    s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.summary      = 'Zilliqa SDK in pure Swift'
    s.homepage     = 'https://github.com/OpenZesame/Zesame'
    s.author       = { "Sajjon" => "alex.cyon@gmail.com" }
    s.source       = { :git => 'https://github.com/OpenZesame/Zesame.git', :tag => 'v' + String(spec.version) }
    s.source_files = 'Source/*.swift'
    s.social_media_url = 'https://twitter.com/alexcyon'

     # ECC Methods
    s.dependency 'EllipticCurveKit'

    # Hash functions
    s.dependency 'CryptoSwift'

    # JSON RPC in order to format API requests (2018-09-28: ollitapas fork contains support for `Codable`)
    s.dependency 'JSONRPCKit', :git => 'git@github.com:ollitapa/JSONRPCKit.git'

    # Sending of JSON RPC requests, recommendend by JSONRPCKit: https://github.com/bricklife/JSONRPCKit#json-rpc-over-http-by-apikit
    s.dependency 'APIKit'

    # Used by this SDK making APIs reactive
    s.dependency 'RxSwift'
      
    end
end