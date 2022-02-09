Gem::Specification.new do |s|
  s.name          = 'safe_monkey_patching'
  s.version       = '0.0.10'
  s.date          = '2020-12-30'
  s.summary       = 'Safe monkey patching'
  s.description   = 'Safe monkey patching'
  s.authors       = ['Andrzej Bisewski']
  s.email         = 'andrzej@bisewski.dev' # xD
  s.files         = Dir.glob('{lib}/**/*') + %w[README.md]
  s.require_path  = 'lib'
  s.license       = 'MIT'

  s.add_dependency 'diffy'
end
