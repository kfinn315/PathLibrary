platform :ios, '11.2'

workspace 'PathLibrary'

use_frameworks!

project 'PathPhoto/PathPhoto.xcodeproj'
project 'PathData/PathData.xcodeproj'
project 'PathMap/PathMap.xcodeproj'
project 'PathLibraryDemo/PathLibraryDemo.xcodeproj'

def common_pods
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'SwiftyBeaver'
    pod 'RandomKit', '~> 5.2.3'
end

def photo_pods
    pod 'AssetsPickerViewController', '~> 2.0'
end

def map_pods
    pod 'RxDataSources', '~> 3.0'
    pod 'RxCoreData', '~> 0.4.0'
end

def data_pods
    pod 'RxDataSources', '~> 3.0'
    pod 'RxCoreData', '~> 0.4.0'
    pod 'SwiftSimplify'
end

abstract_target 'Paths' do
    common_pods
    
    target 'PathData' do
        project 'PathData/PathData.xcodeproj'
        data_pods
    end
    
    target 'PathMap' do
        project 'PathMap/PathMap.xcodeproj'
    end
    
    target 'PathPhoto' do
        project 'PathPhoto/PathPhoto.xcodeproj'
        photo_pods
    end
    
    target 'PathLibraryDemo' do
        project 'PathLibraryDemo/PathLibraryDemo.xcodeproj'
        photo_pods
    end
    
end
