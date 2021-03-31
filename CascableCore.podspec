Pod::Spec.new do |s|
  s.name                     = "CascableCore"
  s.version                  = "9.2.4"
  s.summary                  = "SDK for working with hundreds of Wi-Fi enabled cameras from multiple manufacturers."
  s.homepage                 = "http://developer.cascable.se/"
  s.license                  = { :type => "Proprietary", :text => "See the Cascable Developer Portal for license information." }
  s.author                   = "Cascable AB"
  s.osx.deployment_target    = '10.11'
  s.ios.deployment_target    = '10.0'
  s.default_subspec          = 'iOS'
  s.source                   = { :http => "https://github.com/Cascable/cascablecore-binaries/releases/download/9.2.4/CascableCore.framework.zip" }

  s.subspec 'Mac' do |mac|
    mac.vendored_frameworks       = 'Binaries/Mac/CascableCore.framework', 'Binaries/Mac/StopKit.framework'
    mac.platform                  = :osx
    mac.osx.deployment_target     = '10.11'
  end

  s.subspec 'iOS' do |ios|
    ios.vendored_frameworks       = 'Binaries/iOS/CascableCore.framework', 'Binaries/iOS/StopKit.framework'
    ios.platform                  = :ios
    ios.ios.deployment_target     = '10.0'
    ios.pod_target_xcconfig       = { 'ARCHS[sdk=iphonesimulator*]' => '$(ARCHS_STANDARD_64_BIT)' }
  end
  
end
