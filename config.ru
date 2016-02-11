require './app'

app = Garnet::Application.new

Rack::Handler::WEBrick.run(app, Port: 3000)
