require './app'

use Rack::Static,
    header_rules: [[:all, {'Cache-Control' => 'assets, max-age=86400'}]]

app = Garnet::Application.new

Rack::Handler::WEBrick.run(app, Port: 3000)
