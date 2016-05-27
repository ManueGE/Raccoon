Pod::Spec.new do |spec|

  spec.name         = "RaccoonClient"
  spec.version      = "0.0.1"
  spec.summary      = "A Http client to put together Alamofire, PromiseKit and Raccoon"
  spec.description  = <<-DESC
A Http client to put together Alamofire, PromiseKit and Raccoon
                   DESC
  spec.homepage     = "https://github.com/ManueGE/Raccoon/"
  spec.license      = "MIT"


  spec.author    = "Manuel García-Estañ"
  spec.social_media_url   = "http://twitter.com/ManueGE"

  spec.platform     = :ios, "7.0"
  spec.source       = { :git => "https://github.com/ManueGE/Raccoon.git", :tag => "#{spec.version}" }

  spec.requires_arc = true
  spec.dependency "Raccoon/Core", "~> 0.0"

  # Subspecs
  spec.default_subspec = "CoreData"
  spec.subspec 'Core' do |core|
    core.source_files  = "RaccoonClient/**/*.{swift}"
  end

  spec.subspec 'CoreData' do |core_data|
    core_data.dependency "RaccoonClient/Core"
    core_data.dependency "Raccoon/CoreData"
  end

  spec.subspec 'Realm' do |realm|
    realm.dependency "RaccoonClient/Core"
    realm.dependency "Raccoon/Realm"
  end

end
