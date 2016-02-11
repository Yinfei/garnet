require 'rack'
require 'erb'
require 'ostruct'

module Garnet
  class Application

    ROOT ||= File.expand_path(Dir.pwd)
    LAYOUT ||= ROOT + '/views/layout.erb'

    def erb(file)
      params = build_partial(file)
      layout = File.read(LAYOUT)

      ERB.new(layout).result(params.instance_eval { binding })
    end

    def build_partial(file)
      return OpenStruct.new(content: nil) if file.nil?

      content = ERB.new(File.read(File.expand_path(file))).result(binding)

      OpenStruct.new(content: content)
    end

    def render_view(file_name)
      file = "#{ROOT}/posts/#{file_name}.erb"

      return not_found unless File.exist?(file)

      ['200', {'Content-Type' => 'text/html'}, [erb(file)]]
    end

    def favicon
      favicon_file = File.read(ROOT + '/favicon.ico')

      ['200', {'Content-Type' => 'image/x-icon',
               'Content-Length' => favicon_file.bytesize.to_s }, [favicon_file]]
    end

    def homepage
      ['200', {'Content-Type' => 'text/html'}, [erb(nil)]]
    end

    def not_found
      ['404', {'Content-Type' => 'text/html'}, [erb(ROOT + '/views/404.erb')]]
    end

    def call(env)
      endpoint = Rack::Request.new(env).path

      return homepage if endpoint == '/'
      return favicon  if endpoint == '/favicon.ico'

      render_view(endpoint)
    end
  end
end
