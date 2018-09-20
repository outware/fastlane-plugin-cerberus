# Integrating Cerberus

The plugin is composed of multiple actions but is primarily designed to provide and leverage information in disparate systems such as Jenkins, JIRA, Hockey and git.

1. Generation of release notes from git commit messages, leveraging information available from JIRA in combination with structured commit messages
1. Notification of code changes related by publication of comments in relevent JIRA stories and bugs

This document endevours to present how a developer might integrate the plugin actions into thier own fastlane script to reduce the need for the above to be done manually.

## Making the plugin available to fastlane

The Cerberus plugin can be added to a project by running:

```bash
fastlane add_plugin cerberus
```

## Generating release notes

Generation of release notes using default parameters and comment format is done as follows

```ruby
  release_notes(
    issues: find_jira_tickets,
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
    issues: find_jira_tickets,
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

`find_jira_tickets` by default will retrieve all JIRA tickets from `HEAD` up until the commit hash of the last successful build specified by Jenkins.  It does this by reading `GIT_PREVIOUS_SUCCESSFUL_COMMIT` environment variable which is set by Jenkins for each build.

The developer might like to customise the commits included.  For example you can include the commits between two specific commit hashes as shown below.

```ruby
  jira_tickets = find_jira_tickets(
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
  jira_tickets = find_jira_tickets(
    matching: '(CER-\d+)'
    excluding: '[WIP]'
  )

  release_notes(
    issues: jira_tickets,
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

If there are additional changes that need to be included in the change log that do not have an associated JIRA ticket they can found using the `find_commits` action and included in the release notes with the `include_commits` parameter.

```ruby
  additional_commits = find_commits(
    matching: '\[TECH\]'
  )

  release_notes(
    issues: find_jira_tickets,
    include_commits: additional_commits,
    username: jira_username,
    password: jira_password,
    host: jira_host
  )
```

## Notification of code changes

//TODO: ...