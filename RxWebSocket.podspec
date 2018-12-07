#
# Be sure to run `pod lib lint RxWebSocket.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RxWebSocket"
  s.version          = "2.0.0"
  s.summary          = "Reactive WebSockets"
  s.swift_version    = "4.2"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
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

  s.dependency 'Starscream', '~> 3.06'
  s.dependency 'RxSwift', '~> 4.3'
  s.dependency 'RxCocoa', '~> 4.3'
end
