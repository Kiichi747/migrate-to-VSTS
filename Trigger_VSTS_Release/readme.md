
# Purpose
Triggers VSTS Release from Build, but only for builds of master branch.
To allow a single Build definition that can build all the branches and PRs but will trigger Release only for master builds.

# Configure

1. Pass "releaseid" to the script - id of the Release definition you'd like to trigger.

2. In the security configuration of that Release definition set the "Create releases" permission to "Allow" for "Project Collection Build Service" account.

3. To be able to use SYSTEM_ACCESSTOKEN enable option 'Allow Scripts to Access OAuth Token' for the Build definition.
