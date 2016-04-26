platform :ios, '8.0'
use_frameworks!

target 'raccoon' do
	pod 'Alamofire', '~> 3.3'
end

target 'raccoonTests' do

end

target 'RaccoonCoreData' do
    pod 'Alamofire', '~> 3.3'
    pod 'Groot', '~> 1.2'
end

target 'RaccoonCoreDataTests' do
    pod 'BNRCoreDataStack', '~> 1.2'
end

post_install do |installer|
    `find Pods -regex 'Pods/Groot.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)Groot\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end


