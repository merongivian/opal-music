require 'opal-music'

describe Music::Sequence do
  describe '#play' do
    let(:sequence) do
      Music::Sequence.new(
        Browser::Audio::Context.new,
        170,
        ['D3 h', 'Bb2 h']
      )
    end

    it 'returns the total time played for two half notes' do
      expect(sequence.play.round 1).to eq 1.4
    end

    it 'plays in loop' do
      # FIXME this monkey patches loop to run 2 times, so it returns
      # the play time * 2, we shouldn't be testing the loop
      # directly though, extract this
      module Object
        private

        def loop
          2.times { yield }
        end
      end

      expect(sequence.play(false).round 1).to eq 2.8
    end
  end
end
