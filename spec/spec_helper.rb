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
  class JiraIssue
    class Comments
      class Build
        class << self
          attr_reader :comment
        end

        def self.save(params)
          @comment = params['body']
        end
      end

      def build
        Build
      end
    end

    attr_reader :key
    attr_reader :summary

    def initialize(key, summary)
      @key = key
      @summary = summary
    end

    def comments
      Comments.new
    end
  end

  class StubJiraIssues
    class << self
      attr_writer(:issues)
    end

    def self.jql(client, jql, options = { fields: nil, start_at: nil, max_results: nil, expand: nil, validate_query: true })
      @issues
    end
  end

  def Issue
    StubJiraIssues
  end
end
