# Continuous Delivery scrtips

## Account_stats_and_checks
Scripts to checks health of VSTS account based on custom metrics and alerts.
Can be run as a scheduled build in VSTS.

## Git_Normalize_Line_Endings
Normalize line endings in Git repo for all files that were checked-in with incorrect EOL

## GitUpdater
Synchronizes Git repos found in folder recursively with their remotes.

## Install_TFS-Integration-Tools_in_VirtualBox
Docs for the process of installing TFS Integration Tools and all prerequisites inside Vagrant \ VirtualBox VM based on Windows 2012R2.

## Migrate_Git_to_Git
Moves code between two local Git repos.
History is preserved.
You can choose to move only subdirectory, not the whole repo, and also push it into an arbitrary subdir in the target Git repo.

## Migrate_TFS_to_Git
Migrates TFS (on premises or in VSTS) to Git repository, clean it and push it to remote.

## Trigger_VSTS_Release
Triggers VSTS Release from Build, but only for builds of master branch.
To allow a single Build definition that can build all the branches and PRs but will trigger Release only for master builds.
