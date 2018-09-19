describe Fastlane::Actions::GitTicketsAction do
  describe '#run' do
    it 'doesnt find issues when changelog is empty' do
      result = execute_lane(body: 'git_tickets')

      expect(result).to eq([])
    end

    it 'finds issues when there is a changelog' do
      allow(Fastlane::Actions::ChangelogFromGitCommitsAction)
        .to receive(:run)
        .and_return(
          [
            '[XYZ-312] - Update SSL',
            '[XYZ-312] - Update SSL 2.0',
            '[ZXY-5233] - Update API model',
            'CAB-51 - Update API model',
            '[macc-3213] - Address bug',
            '[TECH] - Remove dead code'
          ].join("\n")
        )

      result = execute_lane(body: 'git_tickets')

      expect(result).to eq(['XYZ-312', 'ZXY-5233', 'CAB-51'])
    end

    describe 'exclude_regex' do
      it 'applies the exclude regex when its provided' do
        allow(Fastlane::Actions::ChangelogFromGitCommitsAction)
          .to receive(:run)
          .and_return(
            [
              '[ZYZ-123] - Update SSL',
              '[xyz-1] - Update API model',
              '[TECH] - Remove dead code'
            ].join("\n")
          )

        result = execute_lane(body: "git_tickets(exclude_regex: '([A-Z]+-\\d+)')")

        expect(result).to eq([])
      end
    end
  end
end
