
set TFS_COLLECTION=https://@@@account@@@.visualstudio.com/@@@collection@@@
set TFS_PATH=$/.../...
set LOCAL_DIR=D:\...\...

set GIT_AUTHOR="USERNAME <EMAILADDRESS>"
set GIT_REPO=https://github.com/@@@user@@@/@@@repo@@@.git
@echo off

rem to ignore changes in this file from git seeng them as untracked changes run:
rem   > git update-index --assume-unchanged <file>
rem to revert this run:
rem   > git update-index --no-assume-unchanged <file>

echo on
