
# Purpose
Triggers VSTS Release from Build, but only for builds of master branch.
To allow a single Build definition that can build all the branches and PRs but will trigger Release only for master builds.

# Configure

1. In Build definition add PowerShell Script step and specify the name of the script.

2. Pass "ReleaseId" to the script - id of the Release definition you'd like to trigger.

3. In the security configuration of that Release definition set the "Create releases" permission to "Allow" for "Project Collection Build Service" account.

4. To allow script to use SYSTEM_ACCESSTOKEN enable option 'Allow Scripts to Access OAuth Token' for the Build definition.

5. Configure Build definition to watch all branches - in Triggers tab in Branch filter enter * (star), ignore warning that "No branches contain the filter text"

6. Configure to use Build definiton for Pull Requests - in Settings \ Version control, select master branch, switch to Branch Policies tab and enable checkbox "When team members create or update a pull request into the master branch, queue this build:", specifying this Build definition. Enable also: "Block pull request completion unless there is a valid build"


# TODO

Consider further steps:
- include this script in Experian.Tooling.Build package
- wrap it into VSTS expension
