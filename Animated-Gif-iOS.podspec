Pod::Spec.new do |s|
  s.name         = "Animated-Gif-iOS"
  s.version      = "1.1.0"
  s.summary      = "A special supporting class for playing GIF animations inline without creating all frames at once. Decodes animation frames on the fly"
  s.homepage     = "https://github.com/Dreddik/Animated-GIF-iPhone.git"
  s.license      = 'MIT'
  s.author       = { "Roman Truba" => "dreddkr@gmail.com", "Stijn Spijker" => "(http://www.stijnspijker.nl/", }
  s.source       = { :git => "https://github.com/Dreddik/Animated-GIF-iPhone.git", :tag => s.version.to_s }
  s.platform     = :ios, '5.0'
  s.source_files = 'AnimateGif/*.{h,m}'
  s.frameworks   = 'Foundation','UIKit'
  s.requires_arc = true
end