require 'browser/audio'
require 'browser/audio/param_schedule'

require 'opal/music/sequence'

module Music
  class Keyboard
    def play
      ac = Browser::Audio::Context.new
      tempo = 132

      lead = [
        '-   e',
        'Bb3 e',
        'A3  e',
        'Bb3 e',
        'G3  e',
        'A3  e',
        'F3  e',
        'G3  e',

        'E3  e',
        'F3  e',
        'G3  e',
        'F3  e',
        'E3  e',
        'F3  e',
        'D3  q',

        '-   e',
        'Bb3 s',
        'A3  s',
        'Bb3 e',
        'G3  e',
        'A3  e',
        'G3  e',
        'F3  e',
        'G3  e',

        'E3  e',
        'F3  e',
        'G3  e',
        'F3  e',
        'E3  s',
        'F3  s',
        'E3  e',
        'D3  q'
      ]

      bass = [
        'D3  q',
        '-   h',
        'D3  q',

        'A2  q',
        '-   h',
        'A2  q',

        'Bb2 q',
        '-   h',
        'Bb2 q',

        'F2  h',
        'A2  h'
      ]

      sequence_lead = Sequence.new(ac, tempo, lead)
      sequence_bass = Sequence.new(ac, tempo, bass)

      # set staccato and smoothing values for maximum coolness
      sequence_lead.staccato  = 0.55
      sequence_bass.staccato  = 0.05
      sequence_bass.smoothing = 0.4

      # lower base
      sequence_lead.gain.gain = 1.0 / 2
      sequence_bass.gain.gain = 0.65 / 2

      # custom effects
      sequence_bass.custom_wave([-1,1,-1,1,-1,1], [1,0,1,0,1,0])
      sequence_lead.custom_wave([-1,-0.9,-0.6,-0.3, 0, 0.3, 0.6, 0.9,1])

      sequence_lead.play
      sequence_bass.play

    end
  end
end
