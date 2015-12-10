require 'rack'

ROOT = File.expand_path(Dir.pwd)
ERB_FILES = Dir[ROOT + '/posts/**/*.erb']

def erb(template)
  path = File.expand_path(template)
  ERB.new(File.read(path)).result(binding)
end

def load_erb(file)
  Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, [erb(file)]] }
end

def relative_file_path(file)
  "/#{file.match(/posts\/(.*).erb/).captures.first}"
end

def routes
  home = { '/' => load_erb(ROOT + '/views/layout.erb') }

  ERB_FILES.each_with_object(home) do |file, response|
    response.merge!({ relative_file_path(file) => load_erb(file) })
    response
  end
end

def app
  run Rack::URLMap.new(routes)
end

Rack::Handler::WEBrick.run app
