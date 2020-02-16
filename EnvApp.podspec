Pod::Spec.new do |s|
  s.name = 'EnvApp'
  s.version = '1.0.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An SDK which implmenents EnvApp validation protocol for iOS'
  s.homepage = 'https://github.com/trickstersio/envapp-sdk-ios'
  s.authors = { 'Alexander Gaidukov' => 'alexander.gaidukov@gmail.com' }
  s.source = { :git => 'https://github.com/trickstersio/envapp-sdk-ios.git', :tag => s.version }

  s.ios.deployment_target = '10.0'

  s.swift_versions = ['5.0', '5.1']

  s.source_files = 'EnvApp/*.swift'
end