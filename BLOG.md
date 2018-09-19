# How to improve traceability in your build pipeline

## Is this for me?

Do you use any of these tools for mobile development?

== small image of logos ==


Do you manually comment about automated events on your tickets?

<br />

Wish your build changelog gave useful information?

== image of a changelog on hockey ==

<br />

Wish JIRA told you about build and deploy events?

== image of a comment on JIRA ==

<br />

Read on, you might find this tool useful.

## Motivation

Using disparate tools came at a cost. The tools operated in silos and exchanged very little information with each other. This made handover of a story from Dev to QA to PO that much harder. Precious project time was being spent on chasing other people.

We took a look at our toolchain and identified areas where information was being lost in transit.

A commit contained the story card it correlates to, but CI did not receive that information from SCM.
CI at this point in time, has no idea what it is building and hence cannot pass this information on to Hockey or Testflight.

== img JIRA > Commit message on Github !> CI !> Artifact Store ==


Since a deployment cannot be correlated to a ticket, the feedback loop is not complete.

== img JIRA > Commit message on Github !> CI !> Artifact Store >> JIRA ==


We created Cerberus to bring back the information that was lost along the way. It works behind the scenes to extract and forward information to tools further down the chain and completes the feedback loop.


## How does it do it?

Cerberus is a collection of tasks that work together to achieve a common goal.

1. Ticket numbers are harvested from commit messages
2. The JIRA API then provides additional information about the tickets
3. The information is collated into a changelog and passed along to tools such as Hockey and Testflight
4. JIRA tickets receives a comment with the link to the deployed artefact(s)

== Img ==

## Where to go from here?

Cerberus is compatible with project that use Fastlane or Gradle. If you would like to give it a spin:

== Add Links here ==

## Conclusion

Cerberus helped us by 'wiring up' tools that wouldn't normally speak to each other. JIRA now serves as a source of truth **and** as a dashboard of information. Our team members don't have to chase up on our tools or chase up each other,  giving them time to think about and solve harder problems.

Do you see an issue with our plugins or want to add a feature? Feel free to submit a PR to Github <link pending>

