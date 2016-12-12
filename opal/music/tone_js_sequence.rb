require 'music/vendor/tone'

module Music
  class ToneJsSequence
    def initialize(audio_context, tempo, notes = [], loop_mode = false)
      # should be setted once
      `Tone.setContext(#{audio_context})`
      @audio_context = audio_context
      @tempo = tempo
      @notes = notes
    end

    def play
    end
  end
end
