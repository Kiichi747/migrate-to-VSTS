
@rem
@rem Sctipt to extract a subfolder from one Git repo with history and move it to a subfolder in another Git repo
@rem


@rem change these values
set SOURCE_REPO=SourceRepoDir
set TARGET_REPO=TargetRepoDir
@rem slash (not back-slash) is important, otherwise it will fail with "assertion failed"
set PREFIX_SOURCE=foo/bar/something
set PREFIX_TARGET=some/subfolder/here





@rem internal script variables, no need to change them
set TEMP_BRANCH=split
set TEMP_REPO=TEMP_REPO





pushd %SOURCE_REPO%
git subtree split -b %TEMP_BRANCH% --prefix=%PREFIX_SOURCE%
popd


git init %TEMP_REPO%
pushd %TEMP_REPO%
git pull ..\%SOURCE_REPO% %TEMP_BRANCH%:master
popd


pushd %TARGET_REPO%
git subtree add --prefix=%PREFIX_TARGET% ..\%TEMP_REPO% HEAD
git push
popd


rmdir /s /q %TEMP_REPO%


@rem TODO: delete temp branch from source repo
pushd %SOURCE_REPO%
git branch -D %TEMP_BRANCH%
popd
