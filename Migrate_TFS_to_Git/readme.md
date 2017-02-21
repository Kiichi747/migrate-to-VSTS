# TFS to Git migration


## What it does
- creates local empty Git repository
- loads TFS changesets and converts them to Git commits in this local Git repository 
- cleans the history from:
  - huge files (e.g. Github denies > 100Mb and does not recommend >50Mb)
  - unnecessary files, like per-user settings files, binaries, caches, etc
- adds example .gitignore, converts existing .tfignore files
- pushes to remote Git repository (e.g. Github or VSTS)


## Prerequisites

1.
We are migrating only 1 branch (for example Trunk) from TFS to Git, according to CD model.
So all the other branches must be merged to such branch prior to migration.
This might require converting folder to branch in TFS, if it's not done yet.

2.
See `install_prereqs.bat` that automates installation of the prerequisites:
- git installed and in %PATH%
- Git TFS installed and in %PATH%: see: https://github.com/git-tfs/git-tfs
- java installed and in %PATH% (used by BFG)
- BFG (tested for 1.12.7): https://rtyley.github.io/bfg-repo-cleaner/
- [optional] Git Credentials Manager


## Usage

1. Use one of the existing `migrate_<project>.ps1` files as an example
2. Copy it to a new file
3. Modify all parameters inside, pay special attention to:
    - $Provide_Gitignore_Files - set it to $True only for the final run of the script as it will generate a Git commit that would conflict with new changes from TFS in further runs of the script
    - $PushGitRepoToRemote - if $True will push to remote Git location (in VSTS), set it to $False if you want just a local test
    - $Remove_Local_Git_Dir - set to $True if you want local Git repository deleted after the final migration run, keep it $False to allow incremental re-runs of the script
4. Run it in PowerShell session, optionally redirecting output to log file. Do not use PowerShell ISE as it has issues when running the script.
5. Review list of cleaned up files from history, that will be printed to output by BFG tool, and will also be recorded in the report files under ..bfg-report subdirectory


## Migration process

Script is made re-runnable to allow incremental migrations.

This makes the whole process less stressful and allows checks in the middle.

However migration is one way from TFS to Git, so do not create commits on the Git side until migration is completely finished, as new changes on both TFS and Git will cause conflicts.

Here is an example migration process:

1. Script is run first time, converting all existing TFS changesets in the chosen branch to Git commits (make sure $Provide_Gitignore_Files = $False and $Remove_Local_Git_Dir = $False).
2. CI build is created in VSTS to build new Git repository.
3. If any issues found with the source code, they can be resolved on the TFS side, creating new TFS changesets.
4. Migration script is run again, and this time it will recognise and migrate only new changesets, so it will run much quicker. 
5. Merge of TFS branches can be done even at this late stage, also creating new TFS changesets.
6. Migration script is run again, synchronising new changes to Git.
7. If everyone is happy with new Git repository, set $Provide_Gitignore_Files = $True and run script again, this will take care about .gitignore files. But this must be the last run of the script.
8. Lock TFS location from changes (using Permissions), and move all the developers to use Git and VSTS.