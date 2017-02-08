#
#  Be sure to run `pod spec lint NSObject-Swizzled.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


s.name         = "NSObject-Swizzled"
s.version      = "1.0.0"
s.summary      = "Object容器异常处理"


s.description  = <<-DESC
防止容器 因nil或者越界造成的崩溃
DESC

s.homepage     = "https://github.com/iOSMaxZN/NSObject-Swizzled"

s.license      = "MIT"

s.author       = { "iOSMax" => "iOSMax_ZN@163.com" }
s.platform     = :ios,'6.0'

s.source       = { :git => "https://github.com/iOSMaxZN/NSObject-Swizzled.git", :tag => "#{s.version}" }
s.source_files = "NSObject+Swizzled/**/*.{h,m}"
s.framework    = "UIKit"
s.module_name  = 'NSObject+Swizzled'

s.requires_arc = false

end
