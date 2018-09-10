require 'fastlane_core/ui/ui'
require 'jira-ruby'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CerberusHelper
      class JiraHelper
       def initialize(host, username, password, context_path, disable_ssl_verification)
        @host = host
        @context_path = context_path
        create_client(host: host, username: username, password: password, context_path: context_path, disable_ssl_verification: disable_ssl_verification)
       end

       def get(issues:)
        return [] if issues.to_a.empty?

        begin
         @client.Issue.jql("KEY IN (#{issues.join(",")})", fields: [:key, :summary], validate_query: false)
        rescue => e
         UI.important 'Jira Client: Failed to get issues.'
         UI.important "Jira Client: Reason - #{e.message}"
         []
        end
       end

       def add_comment(comment:, issues:)
        return if issues.to_a.empty?

        issues.each do |issue|
          begin
            issue.comments.build.save({ 'body' => comment })
          rescue => e
            UI.important "Jira Client: Failed to comment on issues - #{issue.key}"
            UI.important "Jira Client: Reason - #{e.message}"
          end
        end
       end

       def url(issue:)
        [@host, @context_path, 'browse', issue.key].reject(&:empty?).join('/')
       end

       private
       
       def create_client(host:, username:, password:, context_path:, disable_ssl_verification:)
        options = {
         site: host,
         context_path: context_path,
         auth_type: :basic,
         username: username,
         password: password,
         ssl_verify_mode: disable_ssl_verification ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
        }

        @client = JIRA::Client.new(options)
       end
      end

      # class methods that you define here become available in your action
      # as `Helper::CerberusHelper.your_method`
      #
      def self.jira_helper(host:, username:, password:, context_path:, disable_ssl_verification:)
        return JiraHelper.new(host, username, password, context_path, disable_ssl_verification)
      end

      def self.changelog(from:, to:, pretty:, merge_commit_filtering:)
        other_action.changelog_from_git_commits(
          between: [from, to], 
          pretty: pretty,
          merge_commit_filtering: merge_commit_filtering
        )
      end
    end
  end
end
