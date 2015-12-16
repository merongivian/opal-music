module Music
  class Sequence

    attr_accessor :gain, :staccato, :smoothing, :tempo

    def initialize(audio_context, tempo, notes = [])
      @audio_context = audio_context
      @notes         = notes
      @tempo         = tempo
      @staccato      = 0
      @smoothing     = 0
      create_fx_nodes
      create_oscillator
    end

    def push(*extra_notes)
      @notes.concat(extra_notes)
    end

    def play(finite = true)
      when_time ||= @audio_context.current_time

      @oscillator.start(when_time)

      schedule = lambda do
        @notes.each_index do |index|
          when_time = schedule_note(index, when_time)
        end
        schedule.call
      end

      schedule.call

      @oscillator.stop(when_time)
      when_time
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
      stop
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
      prev.connect(@audio_context.destination)
    end

    def schedule_note(index, when_time)
      current_note = get_current_note(index)
      duration = 60 / @tempo * current_note.duration
      cutoff = duration * ( 1 - ( @staccato || 0 ) )
      set_frequency(current_note.frequency, when_time)

      if @smoothing != 0 && current_note.frequency != 0
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
end
