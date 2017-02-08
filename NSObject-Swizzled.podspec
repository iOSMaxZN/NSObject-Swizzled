#
#  Be sure to run `pod spec lint ZNPodDemo.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
s.name         = "NSObject-Swizzled"    #名称
s.version      = "1.0.0"                #版本号
s.summary      = "Swizzled 防止容器异常崩溃"         #简短介绍
s.description  = <<-DESC
处理 因为nil 和 越界造成的崩溃问题。
* Markdown 格式
DESC

s.homepage      = "https://github.com/iOSMaxZN/NSObject-Swizzled"

s.license       = "MIT"
s.author        = { "iOSMax" => "iOSMax_ZN@163.com" }

s.source        = { :git => "https://github.com/iOSMaxZN/NSObject-Swizzled.git", :tag => s.version }

s.platform      = :ios, "6.0"
s.requires_arc  = false

s.source_files  = "NSObjectSwizzled/**/*.{h,m}"

s.frameworks    = 'UIKit'
s.module_name   = 'NSObjectSwizzled'

end
