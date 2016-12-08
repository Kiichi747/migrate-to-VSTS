
# Purpose
Scripts to checks health of VSTS account based on custom metrics and alerts.
Can be run as a scheduled build in VSTS.

## GitRepos.ps1
Scope is Git repositories, their branches and builds.
TODO: Check that master branch has Branch Policies enabled in VSTS, to prevent direct push.

## WorkItems.ps1
Scope is Work Items.
TODO: Measure Lead Time (from Open to Closed).

## Further ideas
Measure Delivery Time for a single line change to Production.
Per project\team.
