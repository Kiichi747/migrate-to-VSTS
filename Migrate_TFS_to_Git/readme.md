# TFS to Git migration

## What it does
- loads TFS repository to local dir
- cleans it history from:
  - huge files (e.g. Github denies > 100Mb and does not recommend >50Mb)
  - unnecessary files, like per-user settings files, binaries, caches, etc
- adds example .gitignore
- pushes to remote Git repository (e.g. Github or VSTS)

## Prerequisites
(see install_prereqs.bat)
- TFS branches are real branches (convert folders to branches)
- [check this? all that's required can be installed as part of Visual Studio] TFS Team Explorer installed: TEE-CLC-14.0.3.zip from
- [optional] Git Credentials Manager
- git installed and in %PATH%
- Git TFS installed and in %PATH%: see: https://github.com/git-tfs/git-tfs
- java installed and in %PATH% (used by BFG)
- BFG 1.12.7: https://rtyley.github.io/bfg-repo-cleaner/

## Usage
1. Modify parameters in file: ```config.bat```
2. Run script as: ```migrate.bat > log.txt 2>&1```
