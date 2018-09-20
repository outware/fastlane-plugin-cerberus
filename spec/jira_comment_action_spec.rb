describe Fastlane::Actions::JiraCommentAction do
  describe '#run' do
    host = 'https://www.jira.com'
    username = 'jira'
    password = 'xyz123'
    build_number = '1'
    build_url = 'https://jenkins.com/build/1'
    app_version = '1.0'
    hockey_url = 'https://hockeyApp.net/app/1'
    stub_jira_client = StubJiraClient.new

    before(:each) do
      allow(FastlaneCore::Helper::CerberusHelper)
        .to receive(:jira_helper) do |params|
          FastlaneCore::Helper::CerberusHelper::JiraHelper.new(
            host: params[:host],
            username: params[:username],
            password: params[:password],
            context_path: params[:context_path],
            disable_ssl_verification: params[:disable_ssl_verification],
            jira_client_helper: stub_jira_client
          )
        end
    end

    after(:each) do
      stub_jira_client.Issue.issues = []
    end

    it 'formats the comment correctly' do
      stub_jira_client.Issue.issues = [StubJiraClient::JiraIssue.new("CER-1", "Summary for: CER-1")]

      execute_lane(
        body: "jira_comment(
          issues: ['CER-1'],
          host: '#{host}',
          username: '#{username}',
          password: '#{password}',
          build_number: '#{build_number}',
          build_url: '#{build_url}',
          app_version: '#{app_version}',
          hockey_url: '#{hockey_url}'
        )"
      )

      expect(StubJiraClient::JiraIssue::Comments::Build.comment).to eq("Jenkins: [Build #1|https://jenkins.com/build/1]\nHockeyApp: [Version 1.0 (1)|https://hockeyApp.net/app/1]")
    end

    it 'doesnt comment when no issues are provided' do
      result = execute_lane(
        body: "jira_comment(
          issues: [],
          host: '#{host}',
          username: '#{username}',
          password: '#{password}',
          build_number: '#{build_number}',
          build_url: '#{build_url}',
          app_version: '#{app_version}',
          hockey_url: '#{hockey_url}'
        )"
      )

      expect(result).to eq(nil)
    end
  end
end
