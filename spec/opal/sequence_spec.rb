require 'opal-music'

describe Music::Sequence do
  let(:sequence) do
    Music::Sequence.new(
      Browser::Audio::Context.new,
      170,
      ['D3 h', '- h']
    )
  end

  before { sequence.wave_type = :sine }

  describe '#play' do
    context 'when played once' do
      it 'returns the total time played for two half notes' do
        expect(sequence.play.round 1).to eq 1.4
      end

      it 'returns the total time for a fixed play start time' do
        expect(sequence.play(1).round 1).to eq 2.4
      end

      it 'plays a muted sequence' do
        expect(sequence).to receive(:stop).once
        expect(sequence.play(nil, false).round 1).to eq 1.4
      end
    end

    it 'doesnt return a number when looping infinitely' do
      sequence.loop_mode = true
      expect(sequence.play).to_not be_a Numeric
    end
  end
end
