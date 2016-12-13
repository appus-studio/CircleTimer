#
# Be sure to run `pod lib lint CircleTimer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AppusCircleTimer"
  s.version          = "0.2.0"
  s.summary          = "'CircleCounter' is a simple in use animated countdown timer"
  s.homepage         = "https://github.com/alexey-kubas-appus/CircleTimer"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Alexey Kubas" => "alexey.kubas@appus.me" }
  s.source           = { :git => "https://github.com/alexey-kubas-appus/CircleTimer.git", :branch => "master", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'CircleTimer'
end
