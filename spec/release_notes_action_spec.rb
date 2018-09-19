describe Fastlane::Actions::ReleaseNotesAction do
  describe '#run' do
    host = 'https://www.jira.com'
    username = 'jira'
    password = 'xyz123'
    build_url = 'https://jenkins.com/build/1'
    stub_jira_client = StubJiraClient.new

    before(:each) do
      allow(FastlaneCore::Helper::CerberusHelper)
        .to receive(:jira_helper) do |params|
          FastlaneCore::Helper::CerberusHelper::JiraHelper.new(
            params[:host],
            params[:username],
            params[:password],
            params[:context_path],
            params[:disable_ssl_verification],
            stub_jira_client
          )
        end
    end

    it 'formats the notes corretly' do
      stub_jira_client.Issue.issues = [StubJiraClient::JiraIssue.new("CER-1", "Summary for: CER-1")]

      result = execute_lane(
        body: "release_notes(
          issues: ['CER-1'],
          host: '#{host}',
          username: '#{username}',
          password: '#{password}',
          build_url: '#{build_url}'
        )"
      )

      expect(result).to eq("### Changelog\n\n- [CER-1](https://www.jira.com/browse/CER-1) - Summary for: CER-1\n\nBuilt by [Jenkins](https://jenkins.com/build/1)")
    end

    it 'formats the notes correctly when no issues are included' do
      result = execute_lane(
        body: "release_notes(
          issues: [],
          host: '#{host}',
          username: '#{username}',
          password: '#{password}',
          build_url: '#{build_url}'
        )"
      )

      expect(result).to eq("### Changelog\n\nNo changes included.\n\nBuilt by [Jenkins](https://jenkins.com/build/1)")
    end
  end
end
