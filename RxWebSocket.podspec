#
# Be sure to run `pod lib lint RxWebSocket.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RxWebSocket"
  s.version          = "1.0.1"
  s.summary          = "Reactive WebSockets"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  Reactive extensions for websockets.

  A lightweight abstraction layer over Starscream to make it reactive.
                       DESC

  s.homepage         = "https://github.com/fjcaetano/RxWebSocket"
  s.license          = 'MIT'
  s.author           = { "Flávio Caetano" => "flavio@vieiracaetano.com" }
  s.source           = { :git => "https://github.com/fjcaetano/RxWebSocket.git", :tag => s.version.to_s }
  s.social_media_url = 'http://twitter.com/flavio_caetano'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'

  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'


# Dependencies

  s.dependency 'Starscream', '~> 2.0.2'
  s.dependency 'RxSwift', '~> 3.0'
  s.dependency 'RxCocoa', '~> 3.0'
end
