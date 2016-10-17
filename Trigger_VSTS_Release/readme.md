
# Purpose

To trigger VSTS Release from Build only for master branch

# Configure

1. Pass "releaseid" to the script - id of the Release definition you'd like to trigger.

2. In the security configuration of that Release definition set the "Create releases" permission to "Allow" for "Project Collection Build Service" account.

3. To be able to use SYSTEM_ACCESSTOKEN enable option 'Allow Scripts to Access OAuth Token' for the Build definition.
