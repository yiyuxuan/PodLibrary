#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'podLibrary'
  s.version          = '0.1.0'
  s.summary          = 'A short description of podLibrary.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage     = "http://gitlab.paifenlecorp.com/paifenleMobile/NetworkBasePod.git"
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "wangcheng" => "251350972@qq.com" }
  # s.source           = { :git => 'https://github.com/${USER_NAME}/${POD_NAME}.git', :tag => s.version.to_s }
  s.source = { :http  => 'https://github.com/yiyuxuan/PodLibrary.git'}
  # http://opes42bvg.bkt.clouddn.com/TestFramework.framework.zip
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.subspec 'lib' do |libResource| 
    libResource.source_files = 'Pod/Classes/lib/**/*'
    libResource.public_header_files = 'Pod/Classes/lib/**/*.h'
    libResource.vendored_libraries = 'Pod/Classes/lib/*.{a}'
  end

  # s.subspec 'resource' do |danmakuFile| 
  #   danmakuFile.source_files = 'Pod/Classes/resource/**/*'
  # end
  # s.default_subspec = 'zip'
  # s.subspec 'zip' do |zip|
  #   puts '-------------------------------------------------------------------'
  #   puts 'Notice: LJWXSDK is zip now'
  #   puts '-------------------------------------------------------------------'
  #   zip.ios.vendored_frameworks = '*.framework'
  # end
  # s.source_files = 'podLibrary/Classes/**/*'
  
  # s.resource_bundles = {
  #   '${POD_NAME}' => ['${POD_NAME}/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
