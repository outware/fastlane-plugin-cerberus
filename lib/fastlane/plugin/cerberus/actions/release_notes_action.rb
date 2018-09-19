require 'fastlane/action'
require_relative '../helper/cerberus_helper'

module Fastlane
  module Actions
    class ReleaseNotesAction < Action
      def self.run(params)
        @jira_helper = Helper::CerberusHelper.jira_helper(
          host: params[:host],
          username: params[:username],
          password: params[:password],
          context_path: params[:context_path],
          disable_ssl_verification: params[:disable_ssl_verification]
        )
        issues = @jira_helper.get(issues: params[:issues])
        Actions.lane_context[SharedValues::FL_CHANGELOG] = comment(issues: issues, include_commits: params[:include_commits], url: params[:buildURL])
      end

      #####################################################
      # @!group Helpers
      #####################################################

      def self.format(issue:)
        "[#{issue.key}](#{@jira_helper.url(issue: issue)}) - #{issue.summary}"
      end

      def self.format_issues(issues:, include_commits:)
        issues.map { |issue| format(issue: issue) }
              .concat(include_commits)
              .map { |change| change.prepend("- ") }
              .join("\n")
      end

      def self.comment(issues:, include_commits:, url:)
        changes = format_issues(issues: issues, include_commits: include_commits)
        changes = 'No changes included.' if changes.to_s.empty?

        changelog = [
          '### Changelog',
          '',
          changes,
          '',
          "Built by [Jenkins](#{url})"
        ].join("\n")

        UI.important(changelog)
        return changelog
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.details
        'Creates a markdown friendly change log from the Jira issues and the Jenkins build url'
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.output
        String
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :issues,
            env_name: 'FL_RELEASE_NOTES_ISSUES',
            description:  'Jira issues',
            optional: false,
            default_value: [],
            type: Array
          ),
          FastlaneCore::ConfigItem.new(
            key: :include_commits,
            env_name: 'FL_HOCKEY_COMMENT_INCLUDE_COMMITS',
            description:  'Additional commits',
            optional: true,
            default_value: [],
            type: Array
          ),
          FastlaneCore::ConfigItem.new(
            key: :buildURL,
            env_name: 'FL_RELEASE_NOTES_BUILD_URL',
            description:  'Link to the ci build',
            optional: false,
            default_value: ENV['BUILD_URL']
          ),
          FastlaneCore::ConfigItem.new(
            key: :username,
            env_name: 'FL_JIRA_USERNAME',
            description:  'Jira user',
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :password,
            env_name: 'FL_JIRA_PASSWORD',
            description:  'Jira user',
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :host,
            env_name: 'FL_JIRA_HOST',
            description:  'Jira location',
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :context_path,
            env_name: 'FL_JIRA_CONTEXT_PATH',
            description:  'Jira context path',
            optional: false,
            default_value: ''
          ),
          FastlaneCore::ConfigItem.new(
            key: :disable_ssl_verification,
            env_name: 'FL_JIRA_DISABLE_SSL_VERIFICATION',
            description:  'Jira SSL Verification mode',
            optional: false,
            default_value: false,
            type: Boolean
          )
        ]
      end

      def self.author
        'Harry Singh <hhs4harry@gmail.com>'
      end
    end
  end
end
