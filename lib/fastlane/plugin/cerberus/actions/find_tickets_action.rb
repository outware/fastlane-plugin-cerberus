require 'fastlane/action'
require_relative '../helper/cerberus_helper'

module Fastlane
  module Actions
    class FindTicketsAction < Action
      def self.run(params)
        regex = Regexp.new(params[:matching])
        changelog = log(from: params[:from], to: params[:to], pretty: params[:pretty])

        if changelog.to_s.empty?
          UI.important('Git Tickets: No changes found.')
          return []
        end

        tickets = tickets(log: changelog, regex: regex)
        exclude_regex = Regexp.new(params[:excluding]) unless params[:excluding].to_s.empty?
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
            env_name: 'FL_FIND_TICKETS_FROM',
            description:  'start commit',
            optional: true,
            default_value: 'HEAD'
          ),
          FastlaneCore::ConfigItem.new(
            key: :to,
            env_name: 'FL_FIND_TICKETS_TO',
            description:  'end commit',
            optional: true,
            default_value: ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT'] || 'HEAD'
          ),
          FastlaneCore::ConfigItem.new(
            key: :matching,
            env_name: 'FL_FIND_TICKETS_MATCHING',
            description:  'regex to extract ticket numbers',
            optional: true,
            default_value: '([A-Z]+-\d+)'
          ),
          FastlaneCore::ConfigItem.new(
            key: :excluding,
            env_name: 'FL_FIND_TICKETS_EXCLUDING',
            description:  'regex to exclude from the change log',
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :pretty,
            env_name: 'FL_FIND_TICKETS_PRETTY_FORMAT',
            description:  'git pretty format',
            optional: true,
            default_value: '* (%h) %s'
          )
        ]
      end

      def self.author
        'Harry Singh <hhs4harry@gmail.com>'
      end
    end
  end
end
