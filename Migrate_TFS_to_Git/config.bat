
@echo off

rem to ignore changes in this file from git seeng them as untracked changes run:
rem   > git update-index --assume-unchanged <file>
rem to revert this run:
rem   > git update-index --no-assume-unchanged <file>

set TFS_COLLECTION=https://@@@account@@@.visualstudio.com/@@@collection@@@
set TFS_PATH=$/.../...
set LOCAL_DIR=D:\...\...

@rem TODO: consider getting first and last changeset ids from TFS by "tf ..." (might require to install Team Explorer Everywhere) to fetch changesets in smaller chunks
set TFS_CHANGESET_FIRST=0
@rem first - to fetch from the very beginning - set to 0 which will complain about invalid number but won't fetch anything at clone stage
set TFS_CHANGESET_LAST=12
@rem last - can be simply set to -1 to fetch all history

set GIT_AUTHOR="USERNAME <EMAILADDRESS>"
set GIT_REPO=https://github.com/@@@user@@@/@@@repo@@@.git

echo on
