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

### [find_tickets](lib/fastlane/plugin/cerberus/actions/find_tickets_action.rb)

This action will extract tickets using a provided regular expression. The default format is as follows:
`ABC-123`, one or more capital letters, followed by a dash, followed by one or more digits.

#### Parameters

| Parameter     | Environment Name                  | Default Value                                         | Description                                                                   |
|-----------    |-------------------------------    |---------------------------------------------------    |------------------------------------------------------------------------------ |
| from          | FL_FIND_TICKETS_FROM              | `'HEAD'`                                              | The commit SHA of the first commit to parse for ticket information.           |
| to            | FL_FIND_TICKETS_TO                | `ENV[GIT_PREVIOUS_SUCCESSFUL_COMMIT]` or `'HEAD'`     | The commit SHA of the last commit to parse for ticket information.            |
| matching      | FL_FIND_TICKETS_MATCHING          | `'([A-Z]+-\d+)'`                                      | Regex which will be used to extract the tickets from the commit messages.     |
| excluding     | FL_FIND_TICKETS_EXCLUDING         |                                                       | Additional regex to ignore specific commits or keywords.                      |
| pretty        | FL_FIND_TICKETS_PRETTY_FORMAT     | `'* (%h) %s'`                                         | [A git log pretty format.](https://git-scm.com/docs/git-log#_pretty_formats)  |

#### Usage

```ruby
find_tickets(
 from: 'HEAD',
 to: '81fae0ffcc714fb56a1c186ae7c73c80442fff74',
 matching: '([A-Z]+-\d+)',
 excluding: 'TECH',
 pretty: '* (%h) %s'
)
```

#### Result

Returns an Array of Strings. e.g `["CER-1", "CER-2"]`

---

### [find_commits](lib/fastlane/plugin/cerberus/actions/find_commits_action.rb)

Extracts the commit messages from a set of commits using regex.

#### Parameters

| Parameter     | Environment Name                  | Default Value                             | Description                                                                   |
|-----------    |-------------------------------    |----------------------------------------   |------------------------------------------------------------------------------ |
| from          | FL_FIND_COMMITS_FROM              | `ENV['FL_FIND_TICKETS_FROM']`             | The commit SHA of the first commit to parse for ticket information.           |
| to            | FL_FIND_COMMITS_TO                | `ENV['FL_FIND_TICKETS_TO']`               | The commit SHA of the last commit to parse for ticket information.            |
| matching      | FL_FIND_COMMITS_MATCHING          | `ENV['FL_FIND_TICKETS_MATCHING']`         | Regex which will be used to extract the tickets from the commit messages.     |
| pretty        | FL_FIND_COMMITS_PRETTY_FORMAT     | `ENV['FL_FIND_TICKETS_PRETTY_FORMAT']`    | [A git log pretty format.](https://git-scm.com/docs/git-log#_pretty_formats)  |

#### Usage

```ruby
find_commits(
 from: 'HEAD',
 to: '81fae0ffcc714fb56a1c186ae7c73c80442fff74',
 matching: 'TECH',
 pretty: '%s'
)
```

#### Result

Returns an Array of Strings. e.g `["[TECH] - Update SSL pinning"]`

---

### [jira_comment](lib/fastlane/plugin/cerberus/actions/jira_comment_action.rb)

Adds a comment on the Jira isses with the CI build number and the link to the CI build it also adds a link to the HockeyApp build and its build number.

#### Parameters

| Parameter                 | Environment Name                  | Default Value                                                 | Description                                           |
|-------------------------- |---------------------------------- |------------------------------------------------------------   |-----------------------------------------------------  |
| issues                    | FL_JIRA_COMMENT_ISSUES            | `[]`                                                          | The Jira issues to comment on. An Array of Strings.   |
| build_number              | FL_JIRA_COMMENT_BUILD_NUMBER      | `ENV['BUILD_NUMBER']`                                         | The CI build number that built the current changes.   |
| build_url                 | FL_JIRA_COMMENT_BUILD_URL         | `ENV['BUILD_URL']`                                            | URL to the CI build.                                  |
| app_version               | FL_JIRA_COMMENT_APP_VERSION       |                                                               | The current app version.                              |
| hockey_url                | FL_JIRA_COMMENT_HOCKEY_URL        | `Actions.lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK]`    | URL to the HockeyApp build.                           |
| username                  | FL_JIRA_USERNAME                  |                                                               | Jira username.                                        |
| password                  | FL_JIRA_PASSWORD                  |                                                               | Jira password.                                        |
| host                      | FL_JIRA_HOST                      |                                                               | Jira host location.                                   |
| context_path              | FL_JIRA_CONTEXT_PATH              | `''`                                                          | Jira context path.                                    |
| disable_ssl_verification  | FL_JIRA_DISABLE_SSL_VERIFICATION  | `false`                                                       | Disable Jira SSL verification.                        |

#### Usage

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

#### Result

Adds a comment on all the issues provided which have an accociated Jira issue in the following format:

```
Jenkins: [Build ##{build_number}|#{build_url}]

HockeyApp: [Version #{app_version} (#{build_number})|#{hockey_url}]
```

---

### [release_notes](lib/fastlane/plugin/cerberus/actions/release_notes_action.rb)

Generates a changelog containing all the completed issues and any additional messages to be included as part of the changelog. It sets the `FL_CHANGELOG` shared value with the changelog.

#### Parameters

| Parameter                 | Environment Name                      | Default Value         | Description                                                               |
|-------------------------- |-----------------------------------    |--------------------   |-------------------------------------------------------------------------  |
| issues                    | FL_RELEASE_NOTES_ISSUES               | `[]`                  | The Jira issues completed as part of this build. An Array of Strings.     |
| include_commits           | FL_HOCKEY_COMMENT_INCLUDE_COMMITS     | `[]`                  | Additional commit messages to be included as part of the release notes.   |
| build_url                 | FL_RELEASE_NOTES_BUILD_URL            | `ENV['BUILD_URL']`    | URL to the CI build.                                                      |
| username                  | FL_JIRA_USERNAME                      |                       | Jira username.                                                            |
| password                  | FL_JIRA_PASSWORD                      |                       | Jira password.                                                            |
| host                      | FL_JIRA_HOST                          |                       | Jira host location.                                                       |
| context_path              | FL_JIRA_CONTEXT_PATH                  | `''`                  | Jira context path.                                                        |
| disable_ssl_verification  | FL_JIRA_DISABLE_SSL_VERIFICATION      | `false`               | Disable Jira SSL verification.                                            |

#### Usage

```ruby
release_notes(
 issues: ['CER-1', 'CER-2'],
 include_commits: ["[TECH] - Add SSL"],
 build_url: 'https://www.jenkins.com/build/1',
 username: 'jenkins',
 password: 'XYZ123',
 host: 'https://jira.com',
 context_path: '',
 disable_ssl_verification: false
)
```

#### Result

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
