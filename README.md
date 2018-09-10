# Cerberus

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-cerberus)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-cerberus`, add it to your project by running:

```bash
fastlane add_plugin cerberus
```

## About

Cerberus is a fastlane plugin for extracting Jira issues from commit messages and sharing information on its respective Jenkins job and HockeyApp upload.
It can generate release notes for use by HockeyApp, and produce Jira comments with Jenkins build and HockeyApp artefact information.

## Actions

### [GitTickets](lib/fastlane/plugin/cerberus/actions/git_tickets_action.rb)

This action will extract tickets using a provided regular expression. The default format is as follows:
`ABC-123`, one or more capital letters, followed by a dash, followed by one or more digits.

##### Parameters

| Parameter         | Environment Name              | Optional  | Default Value                                         | Description                                                                                               |
|---------------    |------------------------------ |---------- |----------------------------------------------------   |-------------------------------------------------------------------------------------------------------    |
| from              | FL_GIT_TICKETS_FROM           | No        | `'HEAD'`                                              | The commit SHA of the first commit to parse for ticket information.                                       |
| to                | FL_GIT_TICKETS_TO             | No        | `ENV[GIT_PREVIOUS_SUCCESSFUL_COMMIT]` or `'HEAD'`     | The commit SHA of the last commit to parse for ticket information.                                        |
| regex             | FL_GIT_TICKETS_REGEX          | No        | `'([A-Z]+-\d+)'`                                      | Regex which will be used to extract the tickets from the commit messages.                                 |
| exclude_regex     | FL_GIT_TICKETS_EXCLUDE_REGEX  | Yes       | `nil`                                                 | Additional regex to ignore specific commits or keywords.                                                  |
| pretty            | FL_GIT_TICKETS_PRETTY_FORMAT  | No        | `'* (%h) %s'`                                         | [A git log pretty format.](https://git-scm.com/docs/git-log#_pretty_formats)                              |

##### Usage

###### Parameters

`fastfile`:
```ruby
git_tickets(
 from: 'HEAD',
 to: '81fae0ffcc714fb56a1c186ae7c73c80442fff74',
 regex: '([A-Z]+-\d+)',
 exclude_regex: 'TECH',
 pretty: '* (%h) %s'
)
```

###### Environment Names


`.env`:
```ruby
FL_GIT_TICKETS_FROM='HEAD'
FL_GIT_TICKETS_TO='81fae0ffcc714fb56a1c186ae7c73c80442fff74'
FL_GIT_TICKETS_REGEX='([A-Z]+-\d+)'
FL_GIT_TICKETS_EXCLUDE_REGEX='TECH'
FL_GIT_TICKETS_PRETTY_FORMAT='* (%h) %s'
```

`fastfile`:
```ruby
git_tickets
```

##### Result

Returns an Array of Strings. e.g `["CER-1", "CER-2"]`

---

### [IncludeCommits](lib/fastlane/plugin/cerberus/actions/include_commits_action.rb)

Extracts the commit messages from a set of commits using regex.

##### Parameters

| Parameter     | Environment Name                  | Optional  | Default Value                             | Description                                                                                               |
|-----------    |---------------------------------- |---------- |---------------------------------------    |-------------------------------------------------------------------------------------------------------    |
| from          | FL_INCLUDE_COMMITS_FROM           | No        | `ENV['FL_GIT_TICKETS_FROM']`              | The commit SHA of the first commit to parse for ticket information.                                       |
| to            | FL_INCLUDE_COMMITS_TO             | No        | `ENV['FL_GIT_TICKETS_TO']`                | The commit SHA of the last commit to parse for ticket information.                                        |
| regex         | FL_INCLUDE_COMMITS_REGEX          | No        | `ENV['FL_GIT_TICKETS_INCLUDE_REGEX']`     | Regex which will be used to extract the tickets from the commit messages.                                 |
| pretty        | FL_INCLUDE_COMMITS_PRETTY_FORMAT  | No        | `ENV['FL_GIT_TICKETS_PRETTY_FORMAT']`     | [A git log pretty format.](https://git-scm.com/docs/git-log#_pretty_formats)                              |

##### Usage

###### Parameters

`fastfile`:
```ruby
include_commits(
 from: 'HEAD',
 to: '81fae0ffcc714fb56a1c186ae7c73c80442fff74',
 regex: 'TECH',
 pretty: '%s'
)
```

###### Environment Names

`.env`:
```ruby
FL_INCLUDE_COMMITS_FROM='HEAD'
FL_INCLUDE_COMMITS_TO='81fae0ffcc714fb56a1c186ae7c73c80442fff74'
FL_INCLUDE_COMMITS_REGEX='TECH'
FL_INCLUDE_COMMITS_PRETTY_FORMAT='%s'
```

`fastfile`:
```ruby
include_commits
```

##### Result

Returns an Array of Strings. e.g `["[TECH] - Update SSL pinning"]`

---

### [JiraComment](lib/fastlane/plugin/cerberus/actions/jira_comment_action.rb)

Adds a comment on the Jira isses with the CI build number and the link to the CI build it also adds a link to the HockeyApp build and its build number.

##### Parameters

| Parameter                 | Environment Name                  | Optional  | Default Value                                                 | Description                                           |
|-------------------------- |---------------------------------- |---------- |------------------------------------------------------------   |-----------------------------------------------------  |
| issues                    | FL_JIRA_COMMENT_ISSUES            | No        | `[]`                                                          | The Jira issues to comment on. An Array of Strings.   |
| build_number              | FL_JIRA_COMMENT_BUILD_NUMBER      | No        | `ENV['BUILD_NUMBER']`                                         | The CI build number that built the current changes.   |
| build_url                 | FL_JIRA_COMMENT_BUILD_URL         | No        | `ENV['BUILD_URL']`                                            | URL to the CI build.                                  |
| app_version               | FL_JIRA_COMMENT_APP_VERSION       | No        | `nil`                                                         | The current app version.                              |
| hockey_url                | FL_JIRA_COMMENT_HOCKEY_URL        | No        | `Actions.lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK]`    | URL to the HockeyApp build.                           |
| username                  | FL_JIRA_USERNAME                  | No        | `nil`                                                         | Jira username.                                        |
| password                  | FL_JIRA_PASSWORD                  | No        | `nil`                                                         | Jira password.                                        |
| host                      | FL_JIRA_HOST                      | No        | `nil`                                                         | Jira host location.                                   |
| context_path              | FL_JIRA_CONTEXT_PATH              | No        | `''`                                                          | Jira context path.                                    |
| disable_ssl_verification  | FL_JIRA_DISABLE_SSL_VERIFICATION  | No        | `false`                                                       | Disable Jira SSL verification.                        |

##### Usage

###### Parameters

`fastfile`:
```ruby
jira_comment(
 issues: ['CER-1', 'CER-2'],
 build_number: '1',
 build_url: 'https://www.jenkins.com/build/1',
 app_version: '1.0-QA',
 hockey_url: 'https://rink.hockeyapp.net/apps/32c5df727eac426',
 username: 'jenkins',
 password: 'XYZ123',
 host: 'https://jira.com',
 context_path: '',
 disable_ssl_verification: false
)
```

###### Environment Names

`.env`:
```ruby
FL_JIRA_COMMENT_ISSUES=['CER-1', 'CER-2']
FL_JIRA_COMMENT_BUILD_NUMBER='1'
FL_JIRA_COMMENT_BUILD_URL='https://www.jenkins.com/build/1'
FL_JIRA_COMMENT_APP_VERSION='1.0-QA'
FL_JIRA_COMMENT_HOCKEY_URL='https://rink.hockeyapp.net/apps/32c5df727eac426'
FL_JIRA_USERNAME='jenkins'
FL_JIRA_PASSWORD='XYZ123'
FL_JIRA_HOST='https://jira.com'
FL_JIRA_CONTEXT_PATH=''
FL_JIRA_DISABLE_SSL_VERIFICATION=false
```

`fastfile`:
```ruby
jira_comment
```

##### Result

Adds a comment on all the issues provided which have an accociated Jira issue in the following format:

```
Jenkins: [Build ##{build_number}|#{build_url}]

HockeyApp: [Version #{app_version} (#{build_number})|#{hockey_url}]
```

---

### [ReleaseNotes](lib/fastlane/plugin/cerberus/actions/release_notes_action.rb)

Generates a changelog containing all the completed issues and any additional messages to be included as part of the changelog. It sets the `FL_CHANGELOG` shared value with the changelog.

##### Parameters

| Parameter                 | Environment Name                      | Optional  | Default Value         | Description                                                               |
|-------------------------- |-----------------------------------    |---------- |--------------------   |-------------------------------------------------------------------------  |
| issues                    | FL_RELEASE_NOTES_ISSUES               | No        | `[]`                  | The Jira issues completed as part of this build. An Array of Strings.     |
| include_commits           | FL_HOCKEY_COMMENT_INCLUDE_COMMITS     | No        | `[]`                  | Additional commit messages to be included as part of the release notes.   |
| build_url                 | FL_RELEASE_NOTES_BUILD_URL            | No        | `ENV['BUILD_URL']`    | URL to the CI build.                                                      |
| username                  | FL_JIRA_USERNAME                      | No        | `nil`                 | Jira username.                                                            |
| password                  | FL_JIRA_PASSWORD                      | No        | `nil`                 | Jira password.                                                            |
| host                      | FL_JIRA_HOST                          | No        | `nil`                 | Jira host location.                                                       |
| context_path              | FL_JIRA_CONTEXT_PATH                  | No        | `''`                  | Jira context path.                                                        |
| disable_ssl_verification  | FL_JIRA_DISABLE_SSL_VERIFICATION      | No        | `false`               | Disable Jira SSL verification.                                            |

##### Usage

###### Parameters

`fastfile`:
```ruby
jira_comment(
 issues: ['CER-1', 'CER-2'],
 build_number: '1',
 build_url: 'https://www.jenkins.com/build/1',
 app_version: '1.0-QA',
 hockey_url: 'https://rink.hockeyapp.net/apps/32c5df727eac426',
 username: 'jenkins',
 password: 'XYZ123',
 host: 'https://jira.com',
 context_path: '',
 disable_ssl_verification: false
)
```

###### Environment Names

`.env`:
```ruby
FL_JIRA_COMMENT_ISSUES=['CER-1', 'CER-2']
FL_JIRA_COMMENT_BUILD_NUMBER='1'
FL_JIRA_COMMENT_BUILD_URL='https://www.jenkins.com/build/1'
FL_JIRA_COMMENT_APP_VERSION='1.0-QA'
FL_JIRA_COMMENT_HOCKEY_URL='https://rink.hockeyapp.net/apps/32c5df727eac426'
FL_JIRA_USERNAME='jenkins'
FL_JIRA_PASSWORD='XYZ123'
FL_JIRA_HOST='https://jira.com'
FL_JIRA_CONTEXT_PATH=''
FL_JIRA_DISABLE_SSL_VERIFICATION=false
```

`fastfile`:
```ruby
jira_comment
```

##### Result

Returns a String containing all the changes and additional messages in the following `markdown` format:
```
### Changelog

- [CER-1](URL): Issue summary
- TECH: Additional commit message

Built by [Jenkins](URL)
```

---

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

**Note to author:** Please set up a sample project to make it easy for users to explore what your plugin does. Provide everything that is necessary to try out the plugin in this project (including a sample Xcode/Android project if necessary)

## Run tests for this plugin

To run both the tests, and code style validation, run

```bash
rake
```

To automatically fix many of the styling issues, use
```bash
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
