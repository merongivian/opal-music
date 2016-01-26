module Music
  class Note
    DURATIONS = { 'w' => 4, 'h' => 2, 'q' => 1, 'e' => 0.5, 's' => 0.25 }
    OFFSETS = {
      "B#" => 0,
      "C"  => 0,
      "C#" => 1,
      "Db" => 1,
      "D"  => 2,
      "D#" => 3,
      "Eb" => 3,
      "E"  => 4,
      "Fb" => 4,
      "E#" => 5,
      "F"  => 5,
      "F#" => 6,
      "Gb" => 6,
      "G"  => 7,
      "G#" => 8,
      "Ab" => 8,
      "A"  => 9,
      "A#" => 10,
      "Bb" => 10,
      "B"  => 11,
      "Cb" => 11
    }

    attr_reader :frequency, :duration

    def initialize(music_note)
      couple = music_note.split
      @frequency = get_frequency(couple.at 0)
      @duration  = DURATIONS[couple.at 1]
    end

    def get_frequency(name)
      return 0 if name =~ /-/
      couple = name.split(/(\d+)/)
      middle_c = 440 * ((2**(1 / 12))**(-9))
      octave_offset = 4
      distance = OFFSETS[couple.at 0]
      octave_diff = (couple[1].to_i || octave_offset) - octave_offset
      freq = distance.nil? ? 0 : middle_c * ((2**(1 / 12))**distance)
      freq * (2**octave_diff)
    end
  end
end
