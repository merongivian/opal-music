#require 'browser/support'
#require 'browser/event/base'
#require 'browser/delay'
#require 'browser/window'

module Music
  class KeyboardSynth
      NOTES = [
        "C",
        "D",
        "E",
        "F",
        "G",
        "A",
        "B",
        "Cb",
        "Eb",
        "Fb",
        "Gb",
        "Ab",
        "Bb",
        "C#",
        "D#",
        "E#",
        "F#",
        "G#",
        "A#",
        "B#"
      ]

    def initialize(audio_context)
      @audio_context = audio_context

      @volume = @audio_context.gain
      @volume.connect(@audio_context.destination)
    end

    def play(key)
      octave2 = NOTES.map { |note| note + "2" }
      octave3 = NOTES.map { |note| note + "3" }
      octave4 = NOTES.map { |note| note + "4" }
      octave6 = NOTES.map { |note| note + "6" }

      row1keys = %w(1 2 3 4 5 6 7 8 9 0)
      row2keys = %w(q w e r t y u i o p)
      row3keys = %w(a s d f g h j k l ;)
      row4keys = %w(z x c v b n m , . /)

      octave_notes = [octave2, octave3, octave4, octave6]
      rows_keys = [row1keys, row2keys, row3keys, row4keys]

      key_note_mappings = rows_keys.zip(octave_notes).map do |keys_notes|
        keys_notes[0].zip(keys_notes[1]).to_h
      end.inject(:merge)

      keyboard_note = key_note_mappings[key]

      note = Note.new("#{keyboard_note} s")

      # kill previous played oscillator before playing
      @oscillator and @oscillator.stop(@audio_context.current_time)
      # create new oscillator
      oscillator_setup
      @oscillator.frequency = note.frequency
      @volume.gain = 1
      @oscillator.start
      @oscillator.stop(@audio_context.current_time + 1)
      keyboard_note
    end

    def stop
      @volume.gain = 1
    end

    def oscillator_setup
      @oscillator = @audio_context.oscillator
      @oscillator.type = 'sine'
      @oscillator.connect(@volume)
    end
  end
end
