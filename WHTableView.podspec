#
# Be sure to run `pod lib lint WHTableView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WHTableView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of WHTableView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wanghonggit/WHTableView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wanghonggit' => '995406924@qq.com' }
  s.source           = { :git => 'https://github.com/wanghonggit/WHTableView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
#  s.source_files = 'WHTableView/Classes/**/*'
  
  s.subspec "Base" do |ss|
      ss.source_files = "WHTableView/Base/*"
  end
  s.subspec "Core" do |ss|
    ss.source_files = "WHTableView/Core/*"
    ss.dependency 'WHTableView/Base'
  end
  s.subspec "Expand" do |ss|
    ss.source_files = "WHTableView/Expand/*"
    ss.dependency 'WHTableView/Core'
    ss.dependency 'WHTableView/Base'
  end
  # s.resource_bundles = {
  #   'WHTableView' => ['WHTableView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
