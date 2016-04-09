#
# Be sure to run `pod lib lint KDTree.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "KDTree"
  s.version          = "0.1.1"
  s.summary          = "Swift implementation of a k-dimensional binary space partitioning tree."

# This description is used to generate tags and improve search results.
  s.description      = "Swift implementation of a k-dimensional binary space partitioning tree. Useful for O(log(N)) nearest neighbour searches."

  s.homepage         = "https://github.com/Bersaelor/KDTree"
  s.screenshots      = "https://raw.githubusercontent.com/Bersaelor/KDTree/master/Screenshots/kNearest.png", "https://raw.githubusercontent.com/Bersaelor/KDTree/master/Screenshots/tesselations.png"
  s.license          = 'MIT'
  s.author           = { "Konrad Feiler" => "konrad@tactica.de" }
  s.source           = { :git => "https://github.com/Bersaelor/KDTree.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bersaelor'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'KDTree' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
