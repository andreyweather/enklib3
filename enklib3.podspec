#
#  Be sure to run `pod spec lint enklib3.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "enklib3"

  spec.version      = "1.0.0"

  spec.summary      = "enklib3 pod for push notifications"

  spec.description  = <<-DESC
  This framework for ios app by enkod for push notification
                   DESC

  spec.homepage     = "https://enkod.io"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "andreyPogodin" => "andreyweather@gmail.com" }

  spec.platform     = :ios, "13.0"

  spec.source       = { :git => "https://github.com/andreyweather/enklib3.git", :tag => "#{spec.version}" }

  spec.source_files  = "enklib3/*.{swift}"

  spec.swift_version = "5.0"

end