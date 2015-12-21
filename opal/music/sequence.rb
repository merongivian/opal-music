module Music
  class Sequence

    attr_accessor :gain, :staccato, :smoothing, :tempo, :notes, :wave_type

    def initialize(audio_context, tempo, notes = [])
      @audio_context = audio_context
      @notes         = notes
      @tempo         = tempo
      @staccato      = 0
      @smoothing     = 0
      create_fx_nodes
    end

    def push(*extra_notes)
      @notes.concat(extra_notes)
    end

    def play(when_time = nil)
      previous_when_time = @audio_context.current_time.tap do |current_time|
        # this is only used when play starts for the first
        # time (if looped)
        when_time ||= current_time
      end

      create_oscillator

      @oscillator.start(when_time)

      @notes.length.times do |index|
        when_time = schedule_note(index, when_time)
      end

      @oscillator.stop(when_time)

      # avoid stack overflow and sinchronize
      # play method call with actual play time
      after(when_time - previous_when_time) do
        @oscillator.when_finished { play(when_time) }
      end
    end

    def custom_wave_type(real, imaginary = nil)
      @wave_type = :custom
      @periodic_wave = @audio_context.periodic_wave(real, imaginary || real)
      @oscillator.periodic_wave = @periodic_wave
    end

    def stop
      return unless @oscillator
      @oscillator.disconnect
      @oscillator = nil
    end

    private

    def create_oscillator
      stop
      @oscillator = @audio_context.oscillator
      # default type
      @oscillator.type = @wave_type
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
      prev.connect(@audio_context.destination)
    end

    def schedule_note(index, when_time)
      current_note = get_current_note(index)
      duration = note_duration(index)
      cutoff = duration * ( 1 - ( @staccato || 0 ) )
      set_frequency(current_note.frequency, when_time)

      if @smoothing != 0 && current_note.frequency != 0
        slide(index, when_time, cutoff)
      end

      set_frequency(0, when_time + cutoff)
      when_time + duration
    end

    def note_duration(index)
      60 / @tempo * get_current_note(index).duration
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
      if @notes[index].is_a?(Note)
        @notes[index]
      else
        Note.new(@notes[index])
      end
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
end
