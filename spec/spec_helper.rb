$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'simplecov'

# SimpleCov.minimum_coverage 95
SimpleCov.start

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/cerberus' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

def execute_lane(body:)
  Fastlane::FastFile.new.parse(
    "lane :test do
      #{body}
     end
    "
  ).runner.execute(:test)
end

class StubJiraClient
end

class StubJiraHelper < FastlaneCore::Helper::CerberusHelper::JiraHelper
  JiraIssue = Struct.new(:key, :summary)

  def initialize
  end

  def get(issues:)
    issues.map do |issue|
      JiraIssue.new(issue, "Summary for: #{issue}")
    end
  end

  def add_comment(comment:, issues:)
    comment
  end
end
