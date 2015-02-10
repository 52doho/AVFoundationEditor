Pod::Spec.new do |s|
  s.name         = "AVFoundationEditor"
  s.version      = '0.0.1'
  s.summary      = "iMovie-like demo app from Bob McCune's \"Mastering Video\" talk. http://bobmccune.com/"
  s.description  = "AVFoundationEditor"
  s.homepage     = "http://bobmccune.com"
  s.license      = "MIT (example)"  
  s.author       = { "bob mccune" => "" }
  s.platform     = :ios, "7.0"
#  s.source       = { :git => "https://github.com/52doho/AVFoundationEditor.git", :branch=> "develop"}
  s.source       = { :git => 'https://github.com/52doho/AVFoundationEditor.git', :tag => "v#{s.version}" }
  s.source_files  = "AVFoundationEditor/Library/**/*.{h,m}"
  s.frameworks = "AVFoundation", "CoreMedia", "CoreText", "AssetsLibrary"
  s.requires_arc = true
end