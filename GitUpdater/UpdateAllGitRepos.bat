
SET mypath=%~dp0
SET mypath=%mypath:~0,-1%

cmd /k powershell.exe -File %mypath%\UpdateAllGitRepos.ps1
