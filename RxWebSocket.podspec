Pod::Spec.new do |s|
  s.name             = "RxWebSocket"
  s.version          = "2.2.0"
  s.summary          = "Reactive WebSockets"
  s.swift_version    = "5.0"

  s.description      = <<-DESC
  Reactive extensions for websockets.

  A lightweight abstraction layer over Starscream to make it reactive.
                       DESC

  s.homepage          = "https://github.com/fjcaetano/RxWebSocket"
  s.license           = 'MIT'
  s.author            = { "Flávio Caetano" => "flavio@vieiracaetano.com" }
  s.source            = { :git => "https://github.com/fjcaetano/RxWebSocket.git", :tag => s.version.to_s }
  s.social_media_url  = 'http://twitter.com/flavio_caetano'
  s.documentation_url = 'http://fjcaetano.github.io/ReCaptcha'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '9.0'

  s.requires_arc = true

  s.source_files = 'Classes/**/*'

  # Dependencies

  s.dependency 'Starscream', '~> 3.0.6'
  s.dependency 'RxSwift', '~> 5.0'
  s.dependency 'RxCocoa', '~> 5.0'
end
