describe Fastlane::Actions::IncludeCommitsAction do
  describe '#run' do
    it 'doesnt find additional commits when changelog is empty' do
      result = execute_lane(body: 'include_commits')

      expect(result).to eq([])
    end

    it 'finds additional commits when it matches the regex' do
      allow(Fastlane::Actions::ChangelogFromGitCommitsAction)
        .to receive(:run)
        .and_return(
          [
            '[CER-1] - HELLO',
            '[CER-2] - TEST',
            '[TECH] - XYZ',
            '[tech] - ZYX'
          ].join("\n")
        )

      result = execute_lane(body: 'include_commits(regex: \'\[([a-zA-Z]+)\]\')')

      expect(result).to eq(['[TECH] - XYZ', '[tech] - ZYX'])
    end
  end
end
