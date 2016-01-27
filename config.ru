require 'opal/rspec'
require 'opal-browser'
require 'opal-audio'

sprockets_env = Opal::RSpec::SprocketsEnvironment.new
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'opal'
  sprockets_env.add_spec_paths_to_sprockets
  s.debug = false
}
