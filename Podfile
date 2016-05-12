platform :ios, '8.0'
use_frameworks!

target 'Raccoon' do
	pod 'Alamofire', '~> 3.4'
end

target 'RaccoonTests' do
end

target 'RaccoonCoreData' do
    pod 'Groot', '~> 1.2'
end

target 'RaccoonCoreDataTests' do
    pod 'BNRCoreDataStack', '~> 1.2'
end

target 'RaccoonRealm' do
    pod 'RealmSwift', '~> 0.102'
end

target 'RaccoonRealmTests' do
end

target 'RaccoonClient' do
    pod 'PromiseKit', '~> 3.1'
end

target 'RaccoonClientTests' do
    pod 'OHHTTPStubs/Swift', '~> 5.0'
end

post_install do |installer|
    `find Pods -regex 'Pods/Groot.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)Groot\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end


