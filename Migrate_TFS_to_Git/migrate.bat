
@rem
@rem TFS to Git migration
@rem

@rem WHAT IT DOES:
@rem - cleanup of huge files (e.g. Github denies > 100Mb and does not recommend >50Mb)
@rem - cleanup of unnecessary files from the history, like per-user settings files, binaries, caches, etc

@rem PRERERQUISITES:
@rem - TFS Team Explorer installed
@rem - git installed and in %PATH%
@rem - Git TFS installed and in %PATH%
@rem - java installed and in %PATH% (used by BFG)
@rem - BFG 1.12.7: https://rtyley.github.io/bfg-repo-cleaner/

@rem USAGE:
@rem   1) Modify parameters below
@rem   2) Run this script as: > get_from_tfs_Dotcom.bat > log.txt 2>&1


@rem Modify these parameters
set TFS_COLLECTION=https://<account>.visualstudio.com/<collection>
set TFS_USERNAME=<domain>\<user>
set TFS_PASSWORD=<password>
set TFS_PATH=$/.../...
set LOCAL_DIR=D:\...\...

set GIT_AUTHOR="USERNAME <EMAILADDRESS>"
set GIT_REPO=https://github.com/<user>/<repo>.git


@rem Internal vars
set CD=%~dp0
set BFG_JAR=%CD%\bfg-1.12.7.jar
set GIT_IGNORE_EXAMPLE_FILE=%CD%\example.gitignore



@echo --- Time: %time%
git tfs clone -u %TFS_USERNAME% -p %TFS_PASSWORD% --ignore-branches --resumable %TFS_COLLECTION% "%TFS_PATH%" %LOCAL_DIR%

@echo --- Time: %time%
cd %LOCAL_DIR%
git tfs pull -r -u %TFS_USERNAME% -p %TFS_PASSWORD%

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --delete-files "{.git,*.dbmdl,*.1,*.2,*.bak,Thumbs.db,*.suo,*.vssscc,*.vspscc,*.vsscc,*.wixpdb,*.wixobj,*.mvfs_*,*.obj,*.pdb,*.user,*.msi}" .

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --delete-folders "{.git,Bin,bin,obj,Debug,debug,backup,Backup,TestResults}" .

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --strip-blobs-bigger-than 50M .

@echo --- Time: %time%
git reflog expire --expire=now --all
git gc --prune=now --aggressive

@echo --- Time: %time%
set TARGET_GITIGNORE_FILE=%LOCAL_DIR%\.gitignore
copy %GIT_IGNORE_EXAMPLE_FILE% %TARGET_GITIGNORE_FILE%
git reset HEAD
git add -v %TARGET_GITIGNORE_FILE%
git commit --author=%GIT_AUTHOR% -m "Adding .gitignore file"

REM TODO: create repo first

@echo --- Time: %time%
git remote add origin %GIT_REPO%
git config --global push.default simple
git push -u origin --all

@echo --- Time: %time%

REM TODO: lock TFS, so no more changes can be checked in there
