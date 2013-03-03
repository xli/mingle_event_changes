Gem::Specification.new do |s|
  s.name = 'mingle_event_changes'
  s.version = '0.0.3'
  s.summary = 'Parse out Mingle Event Feed content element of the entry. Better and simpler API for accessing event changes.'
  s.license = 'MIT'
  s.authors = ["Xiao Li"]
  s.email = 'swing1979@gmail.com'
  s.homepage = 'http://github.com/xli/mingle_event_changes'

  s.add_dependency('sax-machine')

  s.files = ['README']
  s.files += Dir['lib/**/*.rb']
end
