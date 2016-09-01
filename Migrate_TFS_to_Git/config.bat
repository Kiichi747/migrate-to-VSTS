
@echo off

rem to ignore changes in this file from git seeng them as untracked changes run:
rem   > git update-index --assume-unchanged <file>
rem to revert this run:
rem   > git update-index --no-assume-unchanged <file>

set TFS_COLLECTION=https://@@@account@@@.visualstudio.com/@@@collection@@@
set TFS_PATH=$/.../...

@rem TODO: consider getting first and last changeset ids from TFS by "tf ..." to fetch changesets in smaller chunks
@rem   this will require to install Team Explorer Everywhere: https://www.microsoft.com/en-us/download/details.aspx?id=47727
set TFS_CHANGESET_FIRST=1
@rem first - to fetch from the very beginning - set to 1 which will one initial empty commit if first changeset is not 1
set TFS_CHANGESET_LAST=50
@rem last - to fetch till the very end - set to -1

set LOCAL_DIR=D:\...\...

set GIT_AUTHOR="USERNAME <EMAILADDRESS>"
set GIT_REPO=https://github.com/@@@user@@@/@@@repo@@@.git

echo on
