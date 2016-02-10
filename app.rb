require 'rack'
require 'erb'
require 'ostruct'

module Garnet
  class Application

    ROOT ||= File.expand_path(Dir.pwd)
    LAYOUT ||= ROOT + '/views/layout.erb'
    ERB_FILES ||= Dir[ROOT + '/posts/**/*.erb']

    def erb(file)
      params = render_partial(file)

      ERB.new(File.read(LAYOUT)).result(params.instance_eval { binding })
    end

    def render_partial(file)
      return OpenStruct.new(content: nil) if file.nil?

      path = File.expand_path(file)

      OpenStruct.new(content: ERB.new(File.read(path)).result(binding))
    end

    def load_erb(file)
      render = erb(file)

      Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, [render]] }
    end

    def relative_file_path(file)
      "/#{file.match(/posts\/(.*).erb/).captures.first}"
    end

    def home
      { '/' => load_erb(nil) }
    end

    def routes
      ERB_FILES.each_with_object(home) do |file, response|
        response.merge!({ relative_file_path(file) => load_erb(file) })
        response
      end
    end

    def start
      Rack::URLMap.new(routes)
    end
  end
end
