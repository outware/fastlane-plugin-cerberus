module Fastlane
 module Actions

  class IncludeCommitsAction < Action

   def self.run(params)
    regex = Regexp.new params[:regex]
    changelog = log(from: params[:from], to: params[:to], pretty: params[:pretty])

    if !changelog.to_s.empty?
     tickets = tickets(log: changelog, regex: regex)
     UI.important "Additional Issues: #{tickets.join("\n")}"

     return tickets
    else
     UI.important 'No issues found.'
     return []
    end
   end

   def self.details
    'Extracts additional issues from the log'
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
      env_name: 'FL_INCLUDE_COMMITS_FROM',
      description:  'start commit',
      optional: false,
      default_value: ENV['FL_GIT_TICKETS_FROM'] || 'HEAD',
     ),
     FastlaneCore::ConfigItem.new(
      key: :to,
      env_name: 'FL_INCLUDE_COMMITS_TO',
      description:  'end commit',
      optional: false,
      default_value: ENV['FL_GIT_TICKETS_TO'] || ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT'] || 'HEAD'
     ),
     FastlaneCore::ConfigItem.new(
      key: :regex,
      env_name: 'FL_INCLUDE_COMMITS_REGEX',
      description:  'regex to only include to the change log',
      optional: false,
      default_value: ENV['FL_GIT_TICKETS_INCLUDE_REGEX'] || '([A-Z]+-\d+)'
     ),
     FastlaneCore::ConfigItem.new(
      key: :pretty,
      env_name: 'FL_INCLUDE_COMMITS_PRETTY_FORMAT',
      description:  'git pretty format',
      optional: false,
      default_value: ENV['FL_GIT_TICKETS_PRETTY_FORMAT'] || '%s'
     )
    ]
   end

   def self.author
    'Syd Srirak <sydney.srirak@outware.com.au>'
   end

   private

   def self.log(from:, to:, pretty:)
    if to.to_s.empty? || from.to_s.empty?
     UI.important 'Git Tickets: log(to:, from:) cannot be nil'
     return nil
    end

    Helper::CerberusHelper.changelog(
     from: from,
     to: to,
     pretty: pretty,
     merge_commit_filtering: :exclude_merges.to_s
    )
   end

   def self.tickets(log:, regex:)
     return [] if log.to_s.empty?

     log.each_line
     .map { |line| line.strip }
     .grep(regex)
     .flatten
     .reject(&:empty?)
     .uniq
   end
  end
 end
end
