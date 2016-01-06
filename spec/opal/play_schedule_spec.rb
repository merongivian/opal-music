require 'opal-music'

describe Music::PlaySchedule do
  let(:sequence) do
    Music::Sequence.new(
      Browser::Audio::Context.new,
      170,
      ['D3 h', 'Bb2 h']
    )
  end

  let(:play_schedule) { Music::PlaySchedule.new(sequence) }

  before { sequence.wave_type = :sine }

  describe '#start' do
    before do
      play_schedule.volume_array =
        [false, true, true, false, true, false, true]
    end

    it 'schedules sequence play 5 consecutive times' do
      expect(play_schedule.start.round).to eq 10
    end

    it 'mutes on false values' do
      expect(sequence).to receive(:stop).exactly(3).times
      play_schedule.start
    end
  end
end
