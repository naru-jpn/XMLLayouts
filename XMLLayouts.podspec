Pod::Spec.new do |s|
  s.name         = 'XMLLayouts'
  s.version      = '1.1.0'
  s.summary      = 'Template engine for XML'
  s.homepage     = 'http://naru.jpn.com/XMLLayouts'
  s.license      = 'MIT'
  s.author       = { 'naru' }
  s.social_media_url = 'http://twitter.com/naruchigi'
  s.source       = { :git => 'https://github.com/naru-jpn/XMLLayouts.git', :tag => s.version }
  s.requires_arc = true

  s.platform = :ios, '6.0'

  s.source_files  = 'XMLLayouts/*.{h,m}', 'XMLLayouts/**/*.{h,m}', 'XMLLayouts/**/**/*.{h,m}'
  s.public_header_files = 'XMLLayouts/XMLLayouts.{h,m}'
end
