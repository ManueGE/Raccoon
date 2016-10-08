Pod::Spec.new do |spec|

  spec.name         = "Raccoon"
  spec.version      = "0.2.0"
  spec.summary      = "A nice Alamofire serializer that convert JSON into CoreData or Realm objects."
  spec.description  = <<-DESC
  A nice set of protocols and tools that puts together Alamofire, PromiseKit and CoreData
                   DESC
  spec.homepage     = "https://github.com/ManueGE/Raccoon/"
  spec.license      = "MIT"


  spec.author    = "Manuel García-Estañ"
  spec.social_media_url   = "http://twitter.com/ManueGE"

  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/ManueGE/Raccoon.git", :tag => "#{spec.version}" }

  spec.requires_arc = true
  spec.dependency "Alamofire", "~> 4.0"
  spec.dependency "PromiseKit/CorePromise", "~> 4.0"
  spec.dependency "AlamofireCoreData"

  spec.source_files = "Raccoon/source/**/*.{swift}"

  spec.framework  = "CoreData"

end
