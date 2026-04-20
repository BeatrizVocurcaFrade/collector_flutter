Pod::Spec.new do |s|
  s.name             = 'collector_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Real-time resource monitoring for Flutter apps.'
  s.description      = <<-DESC
    Collects FPS, jank, memory, HTTP traffic, CPU usage, battery level
    and custom events with an embedded dashboard and actionable recommendations.
  DESC
  s.homepage         = 'https://github.com/BeatrizVocurcaFrade/collector_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Beatriz Vocurca Frade' => 'beatrizfrade@grupootg.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.0'
end
