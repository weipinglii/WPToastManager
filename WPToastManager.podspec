#
# Be sure to run `pod lib lint WPToastManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WPToastManager'
  s.version          = '0.1.0'
  s.summary          = 'A short description of WPToastManager.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/weiping.lii@icloud.com/WPToastManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weiping.lii@icloud.com' => 'weiping.li@ximalaya.com' }
  s.source           = { :git => 'https://github.com/weiping.lii@icloud.com/WPToastManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '13.0'

  s.source_files = 'WPToastManager/Classes/**/*'
  
  s.resource_bundles = {
     'WPToastManager' => ['WPToastManager/Assets/*']
  }

  s.dependency 'Masonry'
  s.dependency 'YYModel'
  s.dependency 'SDWebImage'
  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Tests/*.{h,m}'
#      test_spec.dependency 'OCMock' # This dependency will only be linked with your tests.
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
