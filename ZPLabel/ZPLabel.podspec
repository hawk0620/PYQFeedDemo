Pod::Spec.new do |s|
  s.name     = 'ZPLabel'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'ZPLabel'
  s.homepage = 'http://github.com/magicalpanda/MagicalRecord'
  s.author   = { 'Saul Mora' => 'saul@magicalpanda.com' }
  s.source   = { :git => 'https://github.com/magicalpanda/MagicalRecord.git', :tag => "v#{s.version}" }
  s.description  = 'Handy fetching, threading and data import helpers to make Core Data a little easier to use.'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.source_files = 'ZPLabel/**/*.{h,m}'

end
  