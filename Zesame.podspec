Pod::Spec.new do |s|
    s.name         = 'Zesame'
    s.version      = '1.0.0'
    s.swift_version = '5.0'
    s.ios.deployment_target = "11.3"
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.summary      = 'Zilliqa SDK in pure Swift'
    s.homepage     = 'https://github.com/OpenZesame/Zesame'
    s.author       = { "Alex Cyon" => "alex.cyon@gmail.com" }
    s.source       = { :git => 'https://github.com/OpenZesame/Zesame.git', :tag => String(s.version) }
    s.source_files = 'Source/**/*.swift'
    s.social_media_url = 'https://twitter.com/alexcyon'

    # ECC Methods
    s.dependency 'EllipticCurveKit', '~> 1.0.0'

    # Hashing functions
    s.dependency 'CryptoSwift', '~> 1.0.0'

    # Used by this SDK making APIs reactive
    s.dependency 'RxSwift'

    s.dependency 'SwiftProtobuf'

    s.dependency 'Alamofire', '~> 5.0.0-beta.3'
end