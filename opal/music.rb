require 'native'
require 'browser'

require 'audio'
require 'audio/param_schedule'

require 'music/note'
require 'music/sequence'
require 'music/play_schedule'

module Music
  def self.audio_context
    Audio::Context.new
  end
end
