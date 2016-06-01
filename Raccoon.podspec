Pod::Spec.new do |spec|

  spec.name         = "Raccoon"
  spec.version      = "0.1.1"
  spec.summary      = "A nice Alamofire serializer that convert JSON into CoreData or Realm objects."
  spec.description  = <<-DESC
  A nice Alamofire serializer that convert JSON into CoreData or Realm objects. Optionally, it provides a Client that puts together Alamofire, PromiseKit and CoreData/Realm
                   DESC
  spec.homepage     = "https://github.com/ManueGE/Raccoon/"
  spec.license      = "MIT"


  spec.author    = "Manuel García-Estañ"
  spec.social_media_url   = "http://twitter.com/ManueGE"

  spec.platform     = :ios, "8.0"
  spec.source       = { :git => "https://github.com/ManueGE/Raccoon.git", :tag => "#{spec.version}" }

  spec.requires_arc = true
  spec.dependency "Alamofire", "~> 3.4"

  # Subspecs
  spec.default_subspec = 'CoreData', 'Client'

  spec.subspec 'Core' do |core|
    core.source_files = "Raccoon/Core/**/*.{swift}"
  end

  spec.subspec 'CoreData' do |core_data|
    core_data.dependency "Raccoon/Core"
    core_data.framework  = "CoreData"
    core_data.dependency "Groot", "~> 1.2"
    core_data.source_files = "Raccoon/CoreData/**/*.{swift}"
  end

  spec.subspec 'Realm' do |realm|
    realm.dependency "Raccoon/Core"
    realm.dependency "RealmSwift", "~> 1.0"
    realm.source_files  = "Raccoon/Realm/**/*.{swift}"
  end

  spec.subspec 'Client' do |client|
    client.dependency "Raccoon/Core"
    client.dependency "PromiseKit/CorePromise", "~> 3.2"
    client.source_files  = "Raccoon/Client/**/*.{swift}"
  end

end
