Pod::Spec.new do |s|
	
  s.name         = "TABSwipeStackView"
  s.version      = "0.1.1"
  s.summary      = "A container for browsing a stack of views using the 'swipe left' and 'swipe right' gestures."

  s.homepage     = "https://github.com/acrocat/TABSwipeStackView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Dale Webster" => "dalewebster48@gmail.com" }
  s.social_media_url   = "http://twitter.com/greatirl"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/acrocat/TABSwipeStackView.git", :tag => "#{s.version}" }
  s.source_files  = "TABSwipeStackView/*.{swift}" , "TABSwipeStackView/Views/*.{swift}","TABSwipeStackView/Animations/*.{swift}"

  s.framework = "UIKit"

end
