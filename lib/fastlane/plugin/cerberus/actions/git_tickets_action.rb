require 'fastlane/action'
require_relative '../helper/cerberus_helper'

module Fastlane
  module Actions
    class GitTicketsAction < Action
      def self.run(params)
        regex = Regexp.new(params[:regex])
        changelog = log(from: params[:from], to: params[:to], pretty: params[:pretty])

        if changelog.to_s.empty?
          UI.important('Git Tickets: No changes found.')
          return []
        end

        tickets = tickets(log: changelog, regex: regex)
        exclude_regex = Regexp.new(params[:exclude_regex]) unless params[:exclude_regex].to_s.empty?
        tickets = filter_tickets(tickets: tickets, exclude_regex: exclude_regex) if exclude_regex
        UI.important("Jira Issues: #{tickets.join(', ')}")
        return tickets
      end

      #####################################################
      # @!group Helpers
      #####################################################

      def self.log(from:, to:, pretty:)
        if to.to_s.empty? || from.to_s.empty?
          UI.important('Git Tickets: log(to:, from:) cannot be nil')
          return nil
        end

        other_action.changelog_from_git_commits(
          between: [from, to],
          pretty: pretty,
          merge_commit_filtering: :exclude_merges.to_s
        )
      end

      def self.tickets(log:, regex:)
        return [] if log.to_s.empty?
        log.each_line
           .map { |line| line.strip.scan(regex) }
           .flatten
           .reject(&:empty?)
           .uniq
      end

      def self.filter_tickets(tickets:, exclude_regex:)
        return [] if tickets.to_s.empty?
        tickets.each.grep_v(exclude_regex)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.details
        'Extracts the Jira issue keys between commits'
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.output
        [String]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :from,
            env_name: 'FL_GIT_TICKETS_FROM',
            description:  'start commit',
            optional: false,
            default_value: 'HEAD'
          ),
          FastlaneCore::ConfigItem.new(
            key: :to,
            env_name: 'FL_GIT_TICKETS_TO',
            description:  'end commit',
            optional: false,
            default_value: ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT'] || 'HEAD'
          ),
          FastlaneCore::ConfigItem.new(
            key: :regex,
            env_name: 'FL_GIT_TICKETS_REGEX',
            description:  'regex to extract ticket numbers',
            optional: false,
            default_value: '([A-Z]+-\d+)'
          ),
          FastlaneCore::ConfigItem.new(
            key: :exclude_regex,
            env_name: 'FL_GIT_TICKETS_EXCLUDE_REGEX',
            description:  'regex to exclude from the change log',
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :pretty,
            env_name: 'FL_GIT_TICKETS_PRETTY_FORMAT',
            description:  'git pretty format',
            optional: false,
            default_value: '* (%h) %s'
          )
        ]
      end

      def self.author
        'Harry Singh <harry.singh@outware.com.au>'
      end
    end
  end
end
