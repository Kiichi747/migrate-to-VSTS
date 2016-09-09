
call config.bat


@rem Internal vars
set CD=%~dp0
set BFG_JAR=%CD%\bfg-1.12.7.jar
set GIT_IGNORE_EXAMPLE_FILE=%CD%\example.gitignore


@echo --- Time: %time%
git tfs quick-clone --changeset=%TFS_CHANGESET_FIRST% --branches=none --resumable "%TFS_COLLECTION%" "%TFS_PATH%" "%LOCAL_DIR%"
@rem not using "clone" command as for some reason it doesn't care about --up-to option
@rem not using "init" command as it doesn't allow to specify start changeset
@rem TODO: consider: --authors=...
@rem TODO: consider: --export --export-work-item-mapping=...
@echo Exited with return code: %ERRORLEVEL%

pushd %LOCAL_DIR%

@echo --- Time: %time%
git tfs fetch --up-to %TFS_CHANGESET_LAST%
@echo Exited with return code: %ERRORLEVEL%
@rem TODO: consider: --batch-size=VALUE (if changesets are huge as default is 100)

@rem git tfs seems to ignore files that cannot be retrieved (e.g. due to intermittent connection), creates commit without the file and continues
@rem so commit is created with missing file, which affects the further history
@rem to deal with this, immeadetely stop the migration process, and revert git repo to the earlier state use command: > git update-ref refs/remotes/tfs/default <commit_id>
@rem then rerun fetch which should re-retrieve dropped changesets

git rebase tfs/default master

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --delete-files "{.git,*.dbmdl,*.1,*.2,*.bak,Thumbs.db,*.suo,*.vssscc,*.vspscc,*.vsscc,*.wixpdb,*.wixobj,*.mvfs_*,*.obj,*.pdb,*.user,*.msi}" .

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --delete-folders "{.git,Bin,bin,obj,Debug,debug,backup,Backup,TestResults}" .

@echo --- Time: %time%
java -jar %BFG_JAR% --no-blob-protection --strip-blobs-bigger-than 50M .

@rem TODO: consider removing git-tfs-id sections from the bottom of the commit messages:
@rem git filter-branch -f --msg-filter 'sed "s/^git-tfs-id:.*$//g"' '--' --all

@rem TODO: Remove the TFS source control bindings from .sln: removing the GlobalSection(TeamFoundationVersionControl) ... EndGlobalSection

@rem As some files were cleaned from the HEAD commit, workspace will still contain them and they will be recognized as new changes, reset will remove them
git reset HEAD --hard

@echo --- Time: %time%
git reflog expire --expire=now --all
git gc --prune=now --aggressive


@rem TODO: Add a .gitattributes file
@echo --- Time: %time%
set TFS_IGNORE_FILE=.tfignore
set GIT_IGNORE_FILE=.gitignore

if exist %GIT_IGNORE_FILE% (
	echo File %GIT_IGNORE_FILE% already exists
) else (
	echo File %GIT_IGNORE_FILE% doesn't exist
	if exist %TFS_IGNORE_FILE% (
		echo Found %TFS_IGNORE_FILE% file, will rename it to %GIT_IGNORE_FILE%
		rename "%TFS_IGNORE_FILE%" "%GIT_IGNORE_FILE%"
		git add -v "%TFS_IGNORE_FILE%" "%GIT_IGNORE_FILE%"
		git commit --author=%GIT_AUTHOR% -m "Renamed %TFS_IGNORE_FILE% to %GIT_IGNORE_FILE%"
	) else (
		echo File %TFS_IGNORE_FILE% doesn't exist
		echo File %GIT_IGNORE_FILE% will be a copy of standard ...
		copy "%GIT_IGNORE_EXAMPLE_FILE%" "%GIT_IGNORE_FILE%"
		git add -v "%GIT_IGNORE_FILE%"
		git commit --author=%GIT_AUTHOR% -m "Adding %GIT_IGNORE_FILE% file based on standard"
	)
)


REM TODO: create repo first

@rem Without this further push might fail.
@rem It repacks git repo into a single pack, cleaning objects left after "git prune".
@rem Might not be compatible with incremental push, or inefficient, as every push will send the whole pack every time.
@rem Consider splitting pack: --max-pack-size=20m
@rem Need further investigation and testing.
REM git repack -adf
@rem run this to check for issues: git fsck --full --dangling

@echo --- Time: %time%
git remote add origin %GIT_REPO%
git config --global push.default simple
git push -u origin --all -v --progress

REM @rem TODO: push in chunks
REM git rev-list --all --count
REM git rev-list master --first-parent --count
REM git push origin master~2500:refs/heads/master
REM git push origin master~2000:refs/heads/master
REM git push origin master~1500:refs/heads/master
REM git push origin master~1000:refs/heads/master
REM git push origin master~500:refs/heads/master
REM git push -u origin master

@echo --- Time: %time%

REM TODO: lock TFS, so no more changes can be checked in there

popd
