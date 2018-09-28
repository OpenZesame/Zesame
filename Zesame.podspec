Pod::Spec.new do |s|
    s.name         = 'Zesame'
    s.version      = '0.0.1'
    s.swift_version = '4.2'
    s.ios.deployment_target = "11.0"
    s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.summary      = 'Zilliqa SDK in pure Swift'
    s.homepage     = 'https://github.com/OpenZesame/Zesame'
    s.author       = { "Alex Cyon" => "alex.cyon@gmail.com" }
    s.source       = { :git => 'https://github.com/OpenZesame/Zesame.git', :tag => String(s.version) }
    s.source_files = 'Source/**/*.swift'
    s.social_media_url = 'https://twitter.com/alexcyon'

     # ECC Methods
    s.dependency 'EllipticCurveKit'

    # JSON RPC in order to format API requests (2018-09-28: ollitapas fork contains support for `Codable`)
    s.dependency 'JSONRPCKit', '~> 4.0.0'#, :git => 'https://github.com/ollitapa/JSONRPCKit'

    # Sending of JSON RPC requests, recommendend by JSONRPCKit: https://github.com/bricklife/JSONRPCKit#json-rpc-over-http-by-apikit
    s.dependency 'APIKit'

    # Used by this SDK making APIs reactive
    s.dependency 'RxSwift'
end