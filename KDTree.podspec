#
# Be sure to run `pod lib lint KDTree.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "KDTree"
  s.version          = "1.1.0"
  s.summary          = "Swift implementation of a k-dimensional binary space partitioning tree."

# This description is used to generate tags and improve search results.
  s.description      = "Swift implementation of a k-dimensional binary space partitioning tree. Useful for O(log(N)) nearest neighbour searches."

  s.homepage         = "https://github.com/Bersaelor/KDTree"
  s.screenshots      = "https://raw.githubusercontent.com/Bersaelor/KDTree/master/Screenshots/kNearest.png", "https://raw.githubusercontent.com/Bersaelor/KDTree/master/Screenshots/tesselations.png"
  s.license          = 'MIT'
  s.author           = { "Konrad Feiler" => "konrad@tactica.de" }
  s.source           = { :git => "https://github.com/Bersaelor/KDTree.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bersaelor'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.2'
  s.requires_arc = true

  s.source_files = 'Sources/*'
end
