Pod::Spec.new do |s|
  s.name         = 'MLActiveRecord'
  s.version      = '1.0.0'
  s.summary      = 'A lightweight Active Record implementation for Core Data.'
  s.homepage     = ''
  s.license      = 'MIT'

  s.author       = { 
    'Joachim Kret' => 'joachim.kret@gmail.com' 
  }

  s.ios.deployment_target = '7.0'

  s.source       = { 
	:git => 'https://github.com/achimk/MLActiveRecord.git',
    :tag => s.version.to_s
  }
  
  s.source_files = 'MLActiveRecord/MLActiveRecord/Source/*.{h,m}'
  s.requires_arc = true
  s.framework  = 'CoreData'
end