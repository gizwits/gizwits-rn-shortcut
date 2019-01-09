
Pod::Spec.new do |s|
  s.name         = "RNGizwitsShortcut"
  s.version      = "1.0.0"
  s.summary      = "RNGizwitsShortcut"
  s.description  = <<-DESC
                  RNGizwitsShortcut
                   DESC
  s.homepage     = "https://github.com/author/RNGizwitsShortcut"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNGizwitsShortcut.git", :tag => "master" }
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  