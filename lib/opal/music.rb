if RUBY_ENGINE == 'opal'
  require 'opal/music/notes'
else
  require 'opal'
  require 'opal/music/version'

  Opal.append_path File.expand_path('../..', __FILE__).untaint
end
