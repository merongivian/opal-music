require 'browser/audio'
require 'opal/music/sequence'

module Music
  class Keyboard
    def play
      ac = Browser::Audio::Context.new
      tempo = 120

      note1 = Music::Note.new('G3 q')
      note2 = Music::Note.new('E4 q')
      note3 = Music::Note.new('C4 h')

      sequence = Music::Sequence.new(ac, tempo);
      sequence.push(note1, note2, note3);

      sequence.loop = false;

      sequence.play

      #ac = Browser::Audio::Context.new
      #lfo = ac.oscillator
      #vca = ac.gain
      #oscillator = ac.oscillator

      #lfo.connect(vca.gain false)
      #oscillator.connect vca
      #vca.connect ac.destination

      #lfo.start
      #lfo.frequency = 4
      #oscillator.start(4)
    end
  end
end
