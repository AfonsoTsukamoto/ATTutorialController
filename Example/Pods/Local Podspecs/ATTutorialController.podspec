#
# Be sure to run `pod lib lint ATTutorialController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ATTutorialController"
  s.version          = "1.0.0"
  s.summary          = "ATTutorialController - A ready to use, UIWindow based controller for tutorials."
  s.description      = <<-DESC
                       - ATTutorial Controller
                       
                       A basic but usefull controller based on UIWindow.
                       With this approach, no view hierarchy loops are necessary to launch your app tutorial and you can even use gestures and another custom actions. 
                       For now, the controller only answers to swipes/taps for next step, but feel free to change it.
                       It also uses the Facebook's Shimmer view, cause its pretty :)
                       DESC
  s.homepage         = "https://github.com/AfonsoTsukamoto/ATTutorialController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Afonso Tsukamoto" => "afonsotsukamoto@ist.utl.pt" }
  s.source           = { :git => "https://github.com/AfonsoTsukamoto/ATTutorialController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/TsukAfonso'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'ATTutorialController' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Shimmer', '~> 1.0.1'
end
