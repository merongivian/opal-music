require 'browser/audio'

module Music
  module Audio
    def self.create_context
      Browser::Audio::Context.new
    end
  end
end

