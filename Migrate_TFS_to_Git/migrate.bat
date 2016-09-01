
call config.bat


@rem Internal vars
set CD=%~dp0
set BFG_JAR=%CD%\bfg-1.12.7.jar
set GIT_IGNORE_EXAMPLE_FILE=%CD%\example.gitignore


@echo --- Time: %time%
git tfs quick-clone --changeset=%TFS_CHANGESET_FIRST% --branches=none --resumable "%TFS_COLLECTION%" "%TFS_PATH%" "%LOCAL_DIR%"
@rem using quick-clone as "clone" command for some reason doesn't care about --up-to option
@rem TODO: consider: --authors=...
@rem TODO: consider: --export --export-work-item-mapping=...

@echo --- Time: %time%
cd %LOCAL_DIR%
git tfs fetch -t %TFS_CHANGESET_LAST%
@rem TODO: consider: --batch-size=VALUE (if changesets are huge, default is 100)

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --delete-files "{.git,*.dbmdl,*.1,*.2,*.bak,Thumbs.db,*.suo,*.vssscc,*.vspscc,*.vsscc,*.wixpdb,*.wixobj,*.mvfs_*,*.obj,*.pdb,*.user,*.msi}" .

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --delete-folders "{.git,Bin,bin,obj,Debug,debug,backup,Backup,TestResults}" .

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --strip-blobs-bigger-than 50M .

@rem TODO: consider removing git-tfs-id sections from the bottom of the commit messages: git filter-branch -f --msg-filter 'sed "s/^git-tfs-id:.*$//g"' '--' --all

@rem TODO: Remove the TFS source control bindings from .sln: removing the GlobalSection(TeamFoundationVersionControl) ... EndGlobalSection

@rem TODO: Add a .gitattributes file

@echo --- Time: %time%
git reflog expire --expire=now --all
git gc --prune=now --aggressive

REM TODO: consider converting .tfignore to .gitignore instead of below
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
