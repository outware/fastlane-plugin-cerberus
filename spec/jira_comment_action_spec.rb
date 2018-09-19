describe Fastlane::Actions::JiraCommentAction do
  describe '#run' do
    host = 'https://www.jira.com'
    username = 'jira'
    password = 'xyz123'
    build_number = '1'
    build_url = 'https://jenkins.com/build/1'
    app_version = '1.0'
    hockey_url = 'https://hockeyApp.net/app/1'

    before(:each) do
      allow(FastlaneCore::Helper::CerberusHelper)
        .to receive(:jira_helper) do |params|
          StubJiraHelper.new
        end
    end

    it 'formats the comment corretly' do
      result = execute_lane(
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

      expect(result).to eq("Jenkins: [Build #1|https://jenkins.com/build/1]\nHockeyApp: [Version 1.0 (1)|https://hockeyApp.net/app/1]")
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
