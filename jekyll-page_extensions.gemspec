Gem::Specification.new do |s|
  s.name        = 'jekyll-page_extensions'
  s.version     = '0.0.2'
  s.date        = '2017-09-09'
  s.summary     = 'Page extensions for Jekyll'
  s.description = 'A plugin for Jekyll that extends the capabilities of the page class'
  s.author      = 'Ulf Möhring'
  s.email       = 'ulf@moehring.me'
  s.homepage    = 'https://github.com/paceline/jekyll-page-extensions'
  s.license     = 'MIT'
  s.files       = ['lib/jekyll-page_extensions.rb']
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.add_runtime_dependency 'activesupport', '> 3'
end
