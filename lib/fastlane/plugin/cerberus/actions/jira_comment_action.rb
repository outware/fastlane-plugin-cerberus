require 'fastlane/action'
require_relative '../helper/cerberus_helper'

module Fastlane
  module Actions
    class JiraCommentAction < Action
      def self.run(params)
        issues = params[:issues]
        return if issues.to_a.empty?

        jira_helper = Helper::CerberusHelper.jira_helper(
          host: params[:host],
          username: params[:username],
          password: params[:password],
          context_path: params[:context_path],
          disable_ssl_verification: params[:disable_ssl_verification]
        )
        issues = jira_helper.get(issues: issues)

        comment = generate_comment(
          build_number: params[:build_number],
          build_url: params[:build_url],
          app_version: params[:app_version],
          hockey_url: params[:hockey_url]
        )

        jira_helper.add_comment(
          comment: comment,
          issues: issues
        )
      end

      #####################################################
      # @!group Helpers
      #####################################################

      def self.generate_comment(build_number:, build_url:, app_version:, hockey_url:)
        [
          "Jenkins: [Build ##{build_number}|#{build_url}]",
          "HockeyApp: [Version #{app_version} (#{build_number})|#{hockey_url}]"
        ].join("\n")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.details
        'This action adds comments on Jira issues with the current build number and url of that build'
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :issues,
            env_name: 'FL_JIRA_COMMENT_ISSUES',
            description:  'jira issue keys',
            optional: true,
            default_value: [],
            type: Array
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_number,
            env_name: 'FL_JIRA_COMMENT_BUILD_NUMBER',
            description:  'CI build number',
            optional: true,
            default_value: ENV['BUILD_NUMBER']
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_url,
            env_name: 'FL_JIRA_COMMENT_BUILD_URL',
            description:  'CI build URL',
            optional: true,
            default_value: ENV['BUILD_URL']
          ),
          FastlaneCore::ConfigItem.new(
            key: :app_version,
            env_name: 'FL_JIRA_COMMENT_APP_VERSION',
            description:  'App version',
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :hockey_url,
            env_name: 'FL_JIRA_COMMENT_HOCKEY_URL',
            description:  'Hockey build url',
            optional: true,
            default_value: Actions.lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK]
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
            optional: true,
            default_value: ''
          ),
          FastlaneCore::ConfigItem.new(
            key: :disable_ssl_verification,
            env_name: 'FL_JIRA_DISABLE_SSL_VERIFICATION',
            description:  'Jira SSL Verification mode',
            optional: true,
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
