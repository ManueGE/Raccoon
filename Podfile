platform :ios, '8.0'
use_frameworks!

abstract_target 'Base' do
    pod 'Alamofire', '~> 3.4'
    
    target 'Raccoon'
    target 'RaccoonTests'
end


abstract_target 'CoreData' do
    pod 'Groot', '~> 1.2'
    
    target 'RaccoonCoreData'
        
    target 'RaccoonCoreDataTests' do
        pod 'Alamofire', '~> 3.4'
        pod 'BNRCoreDataStack', '~> 1.2'
    end
end


abstract_target 'Realm' do
    pod 'RealmSwift', '~> 0.102'
    
    target 'RaccoonRealm'
    
    target 'RaccoonRealmTests' do
        pod 'Alamofire', '~> 3.4'
    end
end



abstract_target 'Client' do
    pod 'PromiseKit', '~> 3.1'
    
    target 'RaccoonClient'
    
    target 'RaccoonClientTests' do
        pod 'Alamofire', '~> 3.4'
        pod 'OHHTTPStubs/Swift', '~> 5.0'
    end
end
