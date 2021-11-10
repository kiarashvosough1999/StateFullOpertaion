Pod::Spec.new do |spec|


  spec.name         = "StateFullOpertaion"
  spec.version      = "0.0.1"
  spec.summary      = "Unleash the power of operation with StateFullOpertaion"


  spec.description  = "Bring States to operation, take control of your application operation with StateFullOpertaion"

  spec.homepage     = "https://github.com/kiarashvosough1999/StateFullOpertaion.git"
  # spec.screenshots  = ""

  
  spec.license      = { :type => "MIT", :file => "LICENSE" }



  spec.author             = { "kiarashvosough1999" => "vosough.k@gmail.com" }
  # spec.social_media_url   = ""

  spec.platform     = :ios
  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "https://github.com/kiarashvosough1999/StateFullOpertaion.git", :tag => "#{spec.version}" }

  spec.source_files  = "StateFullOperation/**/*.{h,m,swift}"
  # spec.exclude_files = "Classes/Exclude"

  spec.swift_versions = ['5.3', '5.4' , '5.5']
  spec.framework = ["UIKit","Foundation"]

end
