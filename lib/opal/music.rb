if RUBY_ENGINE == 'opal'
  require 'opal/music/sequence'
  require 'opal/music/notes'
  require 'native'
else
  require 'opal'
  require 'opal/music/version'

  Opal.append_path File.expand_path('../..', __FILE__).untaint
end
