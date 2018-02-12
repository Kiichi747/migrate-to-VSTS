<# .SYNOPSIS
	Script updates local Git repos when remote Git server has been renamed.
	It searches repositories recursively under a specified directory.
	For each repository it changes the base URL of the remote origin from old to a new value.
	If remote origin does not contain an old value it ignores it, so repos cloned from other sources like github.com are safe.
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
$RemoteOriginName = 'origin'

#
# Functions
#

function ProcessRepo($gitRepoDir) {
	pushd $gitRepoDir

	if (! ((git remote) -match $RemoteOriginName)) {
		Write-Host "$gitRepoDir : ignoring repo without remote $RemoteOriginName"
		popd
		return
	}
	
	$currentOrigin = git remote get-url $RemoteOriginName
	
	if (! ($currentOrigin.StartsWith($OldRemote))) {
		Write-Host "$gitRepoDir : ignoring unknown remote: $currentOrigin"
		popd
		return
	}
	
	$newRemote = $currentOrigin -replace $OldRemote, $NewRemote
	Write-Host "$gitRepoDir : changing $currentOrigin to $newRemote ..."
	git remote set-url $RemoteOriginName $newRemote

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
