@echo off

@rem If path contains spaces coded as %20 then escape percent (%) sign by doubling it, as batch script treat them as var start
SET SourceRepo=<SOURCE_GIT_REPO_URL>
SET TargetRepo=<TARGET_GIT_REPO_URL>

SET LocalFolder=C:\Temp

echo SourceRepo=%SourceRepo%
echo TargetRepo=%TargetRepo%
echo LocalFolder=%LocalFolder%
echo press any key to move repo
pause>nul

IF EXIST %LocalFolder% (
echo folder %LocalFolder% found delete?
@RD /S  %LocalFolder%
)

git clone --mirror %SourceRepo% %LocalFolder%
if ERRORLEVEL 1 goto :EOF

pushd %LocalFolder%

echo press any key to start push to target
pause>nul

git push --mirror %TargetRepo%
if ERRORLEVEL 1 goto :EOF

popd

pause
