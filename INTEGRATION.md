# Integrating Cerberus

* [Making the plugin available to fastlane](#making-the-plugin-available-to-fastlane)
* [Generating release notes](#generating-release-notes)
  + [Customising commits](#customising-commits)
  + [Including additional commits](#including-additional-commits)
  + [Sample Changelog](#sample_changelog)
* [Notification of code changes](#notification-of-code-changes)

The plugin is composed of multiple actions but is primarily designed to provide and leverage information in disparate systems such as Jenkins, JIRA, Hockey and git.

This document endevours to present how a developer might integrate the plugin actions into their own fastlane setup to automate the following manual processes:

1. Generation of release notes from git commit messages, leveraging information available from JIRA in combination with structured commit messages
1. Notification of code changes related by publication of comments in relevent JIRA stories and bugs

## Making the plugin available to fastlane

The Cerberus plugin can be added to a project by running:

```bash
fastlane add_plugin cerberus
```

## Generating release notes

Generation of release notes using default parameters and comment format is done as follows

```ruby
  release_notes(
    issues: find_tickets,
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

This action would normally be called prior to build upload actions such as `upload_to_testflight` and `hockey`.  

The `release_notes` action will set `SharedValues::FL_CHANGELOG` in the lane context which is used by testflight and hockey app upload actions.

If your build is uploaded to another platform without an action that uses `SharedValues::FL_CHANGELOG` the action returns the changelog as a result that can be used as needed.

```ruby
  changelog = release_notes(
    issues: find_tickets,
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

`find_tickets` by default will retrieve all JIRA tickets from `HEAD` up until the commit hash of the last successful build specified by Jenkins.  It does this by reading `GIT_PREVIOUS_SUCCESSFUL_COMMIT` environment variable which is set by Jenkins for each build.

### Customising commits

The developer might like to customise the commits included.  For example you can include the commits between two specific commit hashes as shown below.

```ruby
  jira_tickets = find_tickets(
    from: 'f1ed6916aa6609e04fe9b613e1e8152482e6de5e'
    to: 'c6150a1dbf20e0e8c10d05d9c21a1ce1ee368535'
  )

  release_notes(
    issues: jira_tickets,
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

By default commit comments will be scanned for JIRA issue keys using the following regular expression `([A-Z]+-\d+)`.

The developer can choose to use a different expression for example to gather jira tickets for a specific project only you could customise the `matching` and `excluding` regular expression.

The following will include jira tickets that have `CER` in the issue key and exclude any commits with `[WIP]` in the message.

```ruby
  jira_tickets = find_tickets(
    matching: '(CER-\d+)'
    excluding: '\[WIP\]'
  )

  release_notes(
    issues: jira_tickets,
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

### Including additional commits

If there are additional changes that need to be included in the change log that do not have an associated JIRA ticket they can found using the `find_commits` action and included in the release notes with the `include_commits` parameter.

```ruby
  additional_commits = find_commits(
    matching: '\[TECH\]'
  )

  release_notes(
    issues: find_tickets,
    include_commits: additional_commits,
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

### Sample Changelog

Below is an example of the markdown change log that is created.

```markdown
### Changelog

- [CER-4](https://fakejira.io/browse/CER-4) - The issue summary for JIRA ticket CER-4
- [CER-2](https://fakejira.io/browse/CER-2) - The issue summary for JIRA ticket CER-2
- [CER-1](https://fakejira.io/browse/CER-1) - The issue summary for JIRA ticket CER-1
- [CER-0](https://fakejira.io/browse/CER-0) - The issue summary for JIRA ticket CER-0
- [TECH] - Commit message 2 for fake tech task
- [TECH] - Commit message 1 for fake tech task

Built by [Jenkins](https://fakejenkins.io/job/Cerberus%20Pull%20Request%20Builder/job/cerberus-ios-swift/job/PR-56/5/)
```

It includes the following things...

* Links to JIRA issues and relevant summary from JIRA
* Commit messages for additional commits included
* A link to the relevant build in Jenkins

JIRA information is retrieved using the REST API with the supplied credentials.

By default the link to jenkins is populated using the `BUILD_URL` environment variable, this is set by jenkins.  If you are using a different CI you can customise this by specifying an additional parameter `build_url` when generating the release notes.

## Notification of code changes

The `jira_comment` action will leave a comment with relevant information including the build and hockey app upload urls.

It is recommended to perform this after successful upload to hockey app.

```ruby
  jira_comment(
    issues: find_tickets,
    app_version: '1.0.0',
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

The following is an example of a comment that will be left on tickets.  Build number, and the links to Jenkins and HockeyApp are all populated with defaults but can be customised if necessary.

```
Jenkins: [Build #99](https://fakejenkins.io/job/Cerberus%20Pull%20Request%20Builder/job/cerberus-ios-swift/job/PR-56/5/)
HockeyApp: [Version 1.0.0 (99)](https://rink.hockeyapp.net/apps/x9e607a31399440a8e43c25c5559af2x)
```
