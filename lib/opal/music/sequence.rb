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

  // ================================SEQUENCE===============================
  /*
   * Sequence class
   */

  // create a new Sequence
  function Sequence( ac, tempo, arr ) {
    this.ac = ac;
    this.tempo = tempo || 120;
    this.loop = true;
    this.smoothing = 0;
    this.staccato = 0;
    this.notes = [];
  }

  // create a custom waveform as opposed to "sawtooth", "triangle", etc
  Sequence.prototype.createCustomWave = function( real, imag ) {
    // Allow user to specify only one array and dupe it for imag.
    if ( !imag ) {
      imag = real;
    }

    // Wave type must be custom to apply period wave.
    this.waveType = 'custom';

    // Reset customWave
    this.customWave = [ new Float32Array( real ), new Float32Array( imag ) ];
  };

  // schedules this.notes[ index ] to play at the given time
  // returns an AudioContext timestamp of when the note will *end*
  Sequence.prototype.scheduleNote = function( index, when ) {
    var duration = 60 / this.tempo * this.notes[ index ].duration,
      cutoff = duration * ( 1 - ( this.staccato || 0 ) );

    this.setFrequency( this.notes[ index ].frequency, when );

    if ( this.smoothing && this.notes[ index ].frequency ) {
      this.slide( index, when, cutoff );
    }

    this.setFrequency( 0, when + cutoff );
    return when + duration;
  };

  // get the next note
  Sequence.prototype.getNextNote = function( index ) {
    return this.notes[ index < this.notes.length - 1 ? index + 1 : 0 ];
  };

  // how long do we wait before beginning the slide? (in seconds)
  Sequence.prototype.getSlideStartDelay = function( duration ) {
    return duration - Math.min( duration, 60 / this.tempo * this.smoothing );
  };

  // slide the note at <index> into the next note at the given time,
  // and apply staccato effect if needed
  Sequence.prototype.slide = function( index, when, cutoff ) {
    var next = this.getNextNote( index ),
      start = this.getSlideStartDelay( cutoff );
    this.setFrequency( this.notes[ index ].frequency, when + start );
    this.rampFrequency( next.frequency, when + cutoff );
    return this;
  };

  // set frequency at time
  Sequence.prototype.setFrequency = function( freq, when ) {
    this.osc.frequency.setValueAtTime( freq, when );
    return this;
  };

  // ramp to frequency at time
  Sequence.prototype.rampFrequency = function( freq, when ) {
    this.osc.frequency.linearRampToValueAtTime( freq, when );
    return this;
  };

  // stop playback, null out the oscillator, cancel parameter automation
  Sequence.prototype.stop = function() {
    if ( this.osc ) {
      this.osc.onended = null;
      this.osc.disconnect();
      this.osc = null;
    }
    return this;
  };
}

module Music
  class Sequence
    include Native

    def initialize(audio_context, tempo, notes = [])
      @native        = `new Sequence(#{audio_context.to_n}, tempo)`
      @audio_context = audio_context
      @notes         = notes
      create_fx_nodes
    end

    def loop=(value)
      `#@native.loop = value`
    end

    def push(*extra_notes)
      @notes.concat(extra_notes)
      # send notes back to native object for now
      `#@native.notes = #{@notes.to_n}`
    end

    def play(when_time = nil)
      when_time ||= @audio_context.current_time
      create_oscillator

      @osc.start(when_time)

      @notes.each_with_index do |note, index|
        when_time = `#{@native}.scheduleNote(index, when_time)`
      end

      @osc.stop(when_time)
    end

    private

    # TODO add code for custom oscillator wave
    def create_oscillator
      # what is this for?
      `#{@native}.stop();`
      @osc = @audio_context.oscillator
      @osc.type = :square
      @osc.connect(@gain)
      # TODO erase this when osc var has been
      # fully replaced
      `#{@native}.osc = #{@osc.to_n}`
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
  end

  class Note
    include Native

    def initialize(music_note)
      @native = `new Note(music_note)`
    end
  end
end
