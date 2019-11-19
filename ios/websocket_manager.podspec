#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'websocket_manager'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/luanhssa/flutter_websocket_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'luanhssa' => 'luanhssa@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Starscream', '~> 3.1.1'

  s.ios.deployment_target = '8.0'
end

