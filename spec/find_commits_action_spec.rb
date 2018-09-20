describe Fastlane::Actions::FindCommitsAction do
  describe '#run' do
    it 'doesnt find additional commits when changelog is empty' do
      result = execute_lane(body: 'find_commits')

      expect(result).to eq([])
    end

    it 'finds additional commits when it matches the regex' do
      allow(Fastlane::Actions::ChangelogFromGitCommitsAction)
        .to receive(:run)
        .and_return(
          [
            '[CER-1] - HELLO',
            '[CER-2] - TEST',
            '[CER3] - TEST',
            'CER4 - TEST',
            '[TECH] - XYZ',
            '[tech] - ZYX'
          ].join("\n")
        )

      result = execute_lane(body: 'find_commits(matching: \'\[([a-zA-Z]+)\]\')')

      expect(result).to eq(['[TECH] - XYZ', '[tech] - ZYX'])
    end
  end
end
