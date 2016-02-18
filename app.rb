require 'rack'
require 'erb'
require 'ostruct'

module Garnet
  class Application

    ROOT ||= File.expand_path(Dir.pwd)

    SYSTEM_FILES ||= { 'layout'    => ROOT + '/views/layout.erb',
                       'favicon'   => ROOT + '/favicon.ico',
                       'homepage'  => ROOT + '/views/index.erb',
                       'not_found' => ROOT + '/views/404.erb' }

    HEADERS ||= { 'html' => {'Content-Type' => 'text/html' },
                  'favicon' => { 'Content-Type' => 'image/x-icon',
                                 'Content-Length' => File.read(SYSTEM_FILES['favicon']).bytesize.to_s } }

    def erb(file)
      params = build_partial(file)
      layout = File.read(SYSTEM_FILES['layout'])

      ERB.new(layout).result(params.instance_eval { binding })
    end

    def build_partial(file)
      content = ERB.new(File.read(File.expand_path(file))).result(binding)

      OpenStruct.new(content: content)
    end

    def render_view(file_name)
      file = "#{ROOT}/posts/#{file_name}.erb"

      return not_found unless File.exist?(file)

      ['200', HEADERS['html'], [erb(file)]]
    end

    def asset_file(name)
      file = [ROOT, name].join

      return not_found unless File.exist?(file)

      ['200', HEADERS['html'], [File.read(file)]]
    end

    def favicon
      ['200', HEADERS['favicon'], [File.read(SYSTEM_FILES['favicon'])]]
    end

    def homepage
      ['200', HEADERS['html'], [erb(SYSTEM_FILES['homepage'])]]
    end

    def not_found
      ['404', HEADERS['html'], [erb(SYSTEM_FILES['not_found'])]]
    end

    def call(env)
      endpoint_called = Rack::Request.new(env).path

      return favicon if endpoint_called == '/favicon.ico'
      return homepage if endpoint_called == '/'
      return asset_file(endpoint_called) if endpoint_called =~ /\/assets/

      render_view(endpoint_called)
    end
  end
end
