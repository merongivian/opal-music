module Music
  class PlaySchedule
    attr_accessor :volume_array

    def initialize(sequence, volume_array = [])
      @sequence     = sequence
      @volume_array = volume_array
    end

    def start
      @volume_array.inject(nil) do |total_time, will_play|
        @sequence.play(total_time, will_play)
      end
    end
  end
end
