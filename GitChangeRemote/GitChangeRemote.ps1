<# .SYNOPSIS
	Script updates local Git repos when remote Git server has been renamed.
	It searches for repositories recursively in a specified directory.
	
	For each repository it changes the base URL of all remotes (e.g. origin) from old to a new URL of Git server.
	The matches of old URL is case-insenstive.
	If remote does not contain the old URL it ignores it, so repos cloned from other sources are not touched.
	It also quietly ignores repos without remotes.
	
	Script searches for any git submodules inside a repository, and warns if they also use old Git remote, suggesting to make them relative.
	But it doesn't change submodules itself as this would generate a new commit and it's not always desired.
	To manually convert submodules to be relative, follow this:
		* edit .gitmodules file changing absolute URL to relative, you'll need to figure out if any '../' are required
		* > git submodule sync
		* > git submodule update --init --recursive --remote
		* > git add .gitmodules
		* > git commit -m "Made submodules relative"
		* > git push
		* rerun the script again to make sure there are no more WARNINGs

	References:
	* https://git-scm.com/docs/git-remote#git-remote-emset-urlem
	* https://git-scm.com/docs/git-submodule
	* https://docs.gitlab.com/ce/ci/git_submodules.html
#>

Param (
    [Parameter(Mandatory=$False)]
    [bool] $DryRun = $False,
	
    [Parameter(Mandatory=$False)]
    [string] $RootDir = 'D:\sources',
	
    [Parameter(Mandatory=$False)]
    [string] $OldRemoteBase = 'https://github.com',
	
    [Parameter(Mandatory=$False)]
    [string] $NewRemoteBase = 'https://gitlab.com'
)


#
# Constants
#
$ErrorActionPreference = "Stop"
$modulesFile = '.gitmodules'

#
# Functions
#

function UrlHasBase([string] $url, [string] $base) {
	return $url.StartsWith($base, "CurrentCultureIgnoreCase")
}

function ProcessSubmodules() {
	if (Test-Path $modulesFile) {
		gc $modulesFile | %{
			if ($_ -match 'url\s*=\s*(.+)\s*$') {
				$url = $matches[1]
				if (UrlHasBase $url $OldRemoteBase) {
					Write-Warning "make submodule relative: $url"
				}
			}
		}
	}
}

function ProcessRepo($gitRepoDir) {
	Write-Host "Repo: $gitRepoDir"

	pushd $gitRepoDir

	@(git remote) | %{
		$currentRemote = git remote get-url $_
		
		if (UrlHasBase $currentRemote $OldRemoteBase)
		{
			$newRemote = $NewRemoteBase + $currentRemote.Remove(0, $OldRemoteBase.Length)

			if ($DryRun) {
				Write-Host "`t dry-run, found but not changing $_ : $currentRemote -> $newRemote"
			} else {
				Write-Host "`t changing $_ : $currentRemote -> $newRemote ..."
				git remote set-url $_ $newRemote
			}
		}
		elseif (UrlHasBase $currentRemote $NewRemoteBase)
		{
			Write-Host "`t remote is already updated: $_ : $currentRemote"
		}
		else
		{
			Write-Host "`t ignoring unknown remote: $_ : $currentRemote"
		}
	}
	
	ProcessSubmodules $curDir
	
	popd
}

function ProcessDir([string] $dir) {
	if (Test-Path $dir\.git) {
		ProcessRepo $dir
	} else {
		gci $dir | ?{ $_.PSIsContainer } | %{
			ProcessDir $_.FullName
		}
	}
}

#
# Main
#

ProcessDir $RootDir
