require_relative 'app'

Into.trait(
  author: 'Michael Fellinger',
  title: 'MoxonoM',
  date: lambda{|now| now.strftime('%Y-%m-%d') },
  disqus: false,
  ext: 'md',
  url: 'http://manveru.heroku.com'
)

# Innate.options.mode = :live
Innate.start(root: ::File.dirname(__FILE__), started: true)

use Rack::Static, :urls => [
  '/css', '/js', '/images', '/favicon.ico'
], :root => 'public'

run Innate
