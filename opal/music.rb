require 'native'
require 'browser'

require 'browser/audio'
require 'browser/audio/param_schedule'

require 'music/note'
require 'music/sequence'
require 'music/play_schedule'

module Music
  def self.audio_context
    Browser::Audio::Context.new
  end
end
