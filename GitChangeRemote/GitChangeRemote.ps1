<# .SYNOPSIS
	Script updates local Git repos when remote Git server has been renamed.
	It searches repositories recursively under a specified directory.
	For each repository it changes the base URL of the remote origin from old to a new value.
	If remote origin does not contain an old value it ignores it, so repos cloned from other unknown to script sources are safe.
	It also ignores repos without remote origin.
	
	References:
	* https://git-scm.com/docs/git-remote#git-remote-emset-urlem
#>

Param (
    [Parameter(Mandatory=$False)]
    [string] $RootDir = 'D:\sources',
	
    [Parameter(Mandatory=$False)]
    [string] $OldRemote = 'https://github.com',
	
    [Parameter(Mandatory=$False)]
    [string] $NewRemote = 'https://gitlab.com'
)


#
# Constants
#
$ErrorActionPreference = "Stop"

#
# Functions
#

function ProcessRepo($gitRepoDir) {
	Write-Host "$gitRepoDir"

	pushd $gitRepoDir

	@(git remote) | %{
		$currentOrigin = git remote get-url $_
		
		if ($currentOrigin.StartsWith($OldRemote))
		{
			$newRemote = $currentOrigin -replace $OldRemote, $NewRemote
			Write-Host "`t changing $_ : $currentOrigin -> $newRemote ..."
			git remote set-url $_ $newRemote
		}
		else
		{
			Write-Host "`t unknown remote: $_ : $currentOrigin"
		}
	}
	
	popd
}

function ProcessDir([string] $dir) {
	gci $dir -Dir | %{
		$curDir = $_.FullName
		if (Test-Path $curDir\.git) {
			ProcessRepo $curDir
		} else {
			ProcessDir $curDir
		}
	}
}

#
# Main
#

ProcessDir $RootDir
