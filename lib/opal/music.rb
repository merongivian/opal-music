if RUBY_ENGINE == 'opal'
  require 'opal/music/sequence'
  require 'native'

  require 'browser/audio'
  require 'browser/audio/param_schedule'
else
  require 'opal'
  require 'opal/music/version'

  Opal.append_path File.expand_path('../..', __FILE__).untaint
end
