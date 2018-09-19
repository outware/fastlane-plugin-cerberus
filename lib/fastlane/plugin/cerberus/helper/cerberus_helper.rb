require 'fastlane_core/ui/ui'
require 'jira-ruby'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CerberusHelper
      class JiraClientHelper
        def self.client(host:, username:, password:, context_path:, disable_ssl_verification:)
          options = {
           site: host,
           context_path: context_path,
           auth_type: :basic,
           username: username,
           password: password,
           ssl_verify_mode: disable_ssl_verification ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
          }

          JIRA::Client.new(options)
        end
      end

      class JiraHelper
        def initialize(host, username, password, context_path, disable_ssl_verification, jira_client_helper)
          @host = host
          @context_path = context_path

          jira_client_helper ||= JiraClientHelper.client(
            host: host,
            username: username,
            password: password,
            context_path: context_path,
            disable_ssl_verification: disable_ssl_verification
          )
          @client = jira_client_helper
        end

        def get(issues:)
          return [] if issues.to_a.empty?

          begin
            @client.Issue.jql("KEY IN (#{issues.join(',')})", fields: [:key, :summary], validate_query: false)
          rescue => e
            UI.important('Jira Client: Failed to get issue.')
            UI.important("Jira Client: Reason - #{e.message}")
            []
          end
        end

        def add_comment(comment:, issues:)
          return if issues.to_a.empty?

          issues.each do |issue|
            begin
              issue.comments.build.save({ 'body' => comment })
            rescue => e
              UI.important("Jira Client: Failed to comment on issues - #{issue.key}")
              UI.important("Jira Client: Reason - #{e.message}")
            end
          end
        end

        def url(issue:)
          [@host, @context_path, 'browse', issue.key].reject(&:empty?).join('/')
        end
      end

      def self.jira_helper(host:, username:, password:, context_path:, disable_ssl_verification:)
        return JiraHelper.new(host, username, password, context_path, disable_ssl_verification)
      end
    end
  end
end
