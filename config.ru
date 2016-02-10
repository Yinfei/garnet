require './app'

app = Garnet::Application.new.start

Rack::Handler::WEBrick.run(app, Port: 3000)
