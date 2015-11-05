%x{
   // ================================NOTE===============================
   /*
   * Private stuffz
   */

  var enharmonics = 'B#-C|C#-Db|D|D#-Eb|E-Fb|E#-F|F#-Gb|G|G#-Ab|A|A#-Bb|B-Cb',
    middleC = 440 * Math.pow( Math.pow( 2, 1 / 12 ), -9 ),
    numeric = /^[0-9.]+$/,
    octaveOffset = 4,
    space = /\s+/,
    num = /(\d+)/,
    offsets = {};

  // populate the offset lookup (note distance from C, in semitones)
  enharmonics.split('|').forEach(function( val, i ) {
    val.split('-').forEach(function( note ) {
      offsets[ note ] = i;
    });
  });

  /*
   * Note class
   *
   * new Note ('A4 q') === 440Hz, quarter note
   * new Note ('- e') === 0Hz (basically a rest), eigth note
   * new Note ('A4 es') === 440Hz, dotted eighth note (eighth + sixteenth)
   * new Note ('A4 0.0125') === 440Hz, 32nd note (or any arbitrary
   * divisor/multiple of 1 beat)
   *
   */

  // create a new Note instance from a string
  function Note( str ) {
    var couple = str.split( space );
    // frequency, in Hz
    this.frequency = Note.getFrequency( couple[ 0 ] ) || 0;
    // duration, as a ratio of 1 beat (quarter note = 1, half note = 0.5, etc.)
    this.duration = Note.getDuration( couple[ 1 ] ) || 0;
  }

  // convert a note name (e.g. 'A4') to a frequency (e.g. 440.00)
  Note.getFrequency = function( name ) {
    var couple = name.split( num ),
      distance = offsets[ couple[ 0 ] ],
      octaveDiff = ( couple[ 1 ] || octaveOffset ) - octaveOffset,
      freq = middleC * Math.pow( Math.pow( 2, 1 / 12 ), distance );
    return freq * Math.pow( 2, octaveDiff );
  };

  // convert a duration string (e.g. 'q') to a number (e.g. 1)
  // also accepts numeric strings (e.g '0.125')
  // and compund durations (e.g. 'es' for dotted-eight or eighth plus sixteenth)
  Note.getDuration = function( symbol ) {
    return numeric.test( symbol ) ? parseFloat( symbol ) :
      symbol.toLowerCase().split('').reduce(function( prev, curr ) {
        return prev + ( curr === 'w' ? 4 : curr === 'h' ? 2 :
          curr === 'q' ? 1 : curr === 'e' ? 0.5 :
          curr === 's' ? 0.25 : 0 );
      }, 0 );
  };
}

module Music
  class Sequence
    include Native

    attr_accessor :loop, :gain, :staccato, :smoothing, :tempo

    def initialize(audio_context, tempo, notes = [])
      @audio_context = audio_context
      @notes         = notes
      @tempo         = tempo
      @loop          = true
      @staccato      = 0
      @smoothing     = 0
      create_fx_nodes
      create_oscillator
    end

    def push(*extra_notes)
      @notes.concat(extra_notes)
    end

    def play(when_time = nil)
      when_time ||= @audio_context.current_time

      @oscillator.start(when_time)

      @notes.each_with_index do |note, index|
        when_time = schedule_note(index, when_time)
      end

      @oscillator.stop(when_time)
    end

    def custom_wave_type(real, imaginary = nil)
      @wave_type = :custom
      @periodic_wave = @audio_context.periodic_wave(real, imaginary || real)
      @oscillator.periodic_wave = @periodic_wave
    end

    def wave_type=(oscillator_type)
      @wave_type = @oscillator.type = oscillator_type
    end

    def stop
      return unless @oscillator
      @oscillator.disconnect
      @oscillator = nil
    end

    private

    def create_oscillator
      # TODO use customized stop function
      #`#{@native}.stop();`
      @oscillator = @audio_context.oscillator
      # default type
      @oscillator.type = :square
      @oscillator.connect(@gain)
    end

    def create_fx_nodes
      eq = { bass: 100, mid: 1000, treble: 2500 }
      prev = @gain = @audio_context.gain
      # why is it connecting all eq nodes sequentially ?
      eq.each do |eq_type, value|
        filter = instance_variable_set("@#{eq_type}", @audio_context.biquad_filter)
        filter.type = :peaking
        filter.frequency = value
        prev.connect(prev = filter)
      end
      prev.connect(@audio_context.destination);
    end

    def schedule_note(index, when_time)
      current_note = get_current_note(index)
      duration = 60 / @tempo * current_note.duration
      cutoff = duration * ( 1 - ( @staccato || 0 ) );
      set_frequency(current_note.frequency, when_time);

      if (@smoothing != 0 && current_note.frequency != 0)
        slide(index, when_time, cutoff)
      end

      set_frequency(0, when_time + cutoff)
      when_time + duration
    end

    def slide(index, when_time, cutoff)
      current_note = get_current_note(index)
      next_note = get_next_note(index)

      start = get_slide_start_delay(cutoff)

      set_frequency(current_note.frequency, when_time + start)
      ramp_frequency(next_note.frequency, when_time + cutoff)
    end

    def get_next_note(index)
      next_note = @notes[index < (@notes.length) -1 ? index + 1 : 0]
      next_note.is_a?(Note) ? next_note : Note.new(next_note)
    end

    def get_current_note(index)
      current_note = @notes[index].is_a?(Note) ? @notes[index] : Note.new(@notes[index])
    end

    def get_slide_start_delay(duration)
      duration - [ duration, (60 / @tempo * @smoothing) ].min
    end

    def set_frequency(freq, when_time)
      scheduler = Browser::Audio::ParamSchedule.new(@oscillator.frequency false)
      scheduler.value(freq, when_time)
    end

    def ramp_frequency(freq, when_time)
      scheduler = Browser::Audio::ParamSchedule.new(@oscillator.frequency false)
      scheduler.linear_ramp_to(freq, when_time)
    end
  end

  class Note
    include Native

    alias_native :duration
    alias_native :frequency

    def initialize(music_note)
      @native = `new Note(music_note)`
    end
  end
end
