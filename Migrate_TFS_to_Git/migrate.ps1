Param(
    [Parameter(Mandatory=$False)]
    [string] $TFS_Collection_URL,
	
    [Parameter(Mandatory=$False)]
    [string] $TFS_Path,
	
	# TODO: consider getting first and last changeset ids from TFS by "tf ..." to fetch changesets in smaller chunks
	# this will require to install Team Explorer Everywhere: https://www.microsoft.com/en-us/download/details.aspx?id=47727

	# first - to fetch from the very beginning - set to 1 which will one initial empty commit if first changeset is not 1
    [Parameter(Mandatory=$False)]
    [int] $TFS_Changeset_First = 1,
	
	# last - to fetch till the very end - set to -1
    [Parameter(Mandatory=$False)]
    [int] $TFS_Changeset_Last = -1,
	
    [Parameter(Mandatory=$False)]
    [string] $Local_Git_Dir,
	
    [Parameter(Mandatory=$False)]
    [bool] $Remove_Local_Git_Dir = $True,
	
    # This is only for additional commits done after migration, for example preparing .gitignore files
	[Parameter(Mandatory=$False)]
    [string] $Git_Author,
	
	# Where to push final Git repo, for example URL of new empty Git repo in VSTS
    [Parameter(Mandatory=$False)]
    [string] $Git_Repo
)

#
# Constants
#
$ErrorActionPreference = "Stop"
$scriptdir = Split-Path $MyInvocation.MyCommand.Path
$bfg_jar = Join-Path $scriptdir 'bfg-1.12.7.jar'
$Git_ignore_example_file = Join-Path $scriptdir 'example.gitignore'

#
# Functions
#
function WhatTimeIsItNow() {
	Get-Date -Format g
}

function Write-Host-Formatted([string] $str) {
	Write-Host (WhatTimeIsItNow) ":" $str -ForegroundColor green
}

function InitGitRepoLinkedToTFS() {
	Write-Host-Formatted "Initializing Git repo ..."
	
	git tfs quick-clone --changeset=$TFS_Changeset_First --branches=none --resumable "$TFS_Collection_URL" "$TFS_Path" "$Local_Git_Dir"
	if (! $?) { throw "ERROR: exited with return code: $LASTEXITCODE" }
	# not using "clone" command as for some reason it doesn't care about --up-to option
	# not using "init" command as it doesn't allow to specify start changeset
	# TODO: consider: --authors=...
	# TODO: consider: --export --export-work-item-mapping=...
}

function FetchAllChangesetsAndConvertToCommits() {
	Write-Host-Formatted "Fetching TFS changesets and converting them to Git commits ..."

	git tfs fetch --up-to $TFS_Changeset_Last
	if (! $?) { throw "ERROR: exited with return code: $LASTEXITCODE" }
	# TODO: consider: --batch-size=VALUE (if changesets are huge as default is 100)

	# git tfs seems to ignore files that cannot be retrieved (e.g. due to intermittent connection), creates commit without the file and continues
	# so commit is created with missing file, which affects the further history
	# to deal with this, immeadetely stop the migration process, and revert git repo to the earlier state use command: > git update-ref refs/remotes/tfs/default <commit_id>
	# then rerun fetch which should re-retrieve dropped changesets

	git rebase tfs/default master
}

function CleanupGitRepo() {
	Write-Host-Formatted "Cleaning Git repo: stage 1 ..."
	java -jar $bfg_jar --no-blob-protection --delete-files "{.git,*.dbmdl,*.1,*.2,*.bak,Thumbs.db,*.suo,*.vssscc,*.vspscc,*.vsscc,*.wixpdb,*.wixobj,*.mvfs_*,*.obj,*.user,*.msi}" .

	Write-Host-Formatted "Cleaning Git repo: stage 2 ..."
	java -jar $bfg_jar --no-blob-protection --delete-folders "{.git,Bin,bin,obj,Debug,debug,backup,Backup,TestResults}" .

	Write-Host-Formatted "Cleaning Git repo: stage 3 ..."
	java -jar $bfg_jar --no-blob-protection --strip-blobs-bigger-than 50M .

	Write-Host-Formatted "Cleaning Git repo: stage 4 ..."
	# As some files were cleaned from the HEAD commit, workspace will still contain them and they will be recognized as new changes, reset will remove them
	git reset HEAD --hard

	
	# TODO: consider removing git-tfs-id sections from the bottom of the commit messages:
	# git filter-branch -f --msg-filter 'sed "s/^git-tfs-id:.*$//g"' '--' --all

	# TODO: Remove the TFS source control bindings from .sln: removing the GlobalSection(TeamFoundationVersionControl) ... EndGlobalSection

	Write-Host-Formatted "Cleaning Git repo: stage 5 ..."
	git reflog expire --expire=now --all

	Write-Host-Formatted "Cleaning Git repo: stage 6 ..."
	git gc --prune=now --aggressive
}

function Provide_Gitignore_Files() {
	Write-Host-Formatted "Preparing .gitignore file ..."

	$TFS_Ignore_File = '.tfignore'
	$Git_Ignore_File = '.gitignore'

	# TODO: search for .tfignore recursively: Get-ChildItem . -Recurse -Include $TFS_Ignore_File | %{ ... }
	if (Test-Path $Git_Ignore_File) {
		Write-Host "File $Git_Ignore_File already exists"
	} else {
		Write-Host "File $Git_Ignore_File doesn't exist"
		if (Test-Path $TFS_Ignore_File) {
			Write-Host "Found $TFS_Ignore_File file, will rename it to $Git_Ignore_File"
			Rename-Item "$TFS_Ignore_File" "$Git_Ignore_File"
			git add -v "$TFS_Ignore_File" "$Git_Ignore_File"
			git commit --author=$Git_Author -m "Renamed $TFS_Ignore_File to $Git_Ignore_File"
		} else {
			Write-Host "File $TFS_Ignore_File doesn't exist"
			Write-Host "File $Git_Ignore_File will be a copy of standard ..."
			Copy-Item "$Git_ignore_example_file" "$Git_Ignore_File"
			git add -v "$Git_Ignore_File"
			git commit --author=$Git_Author -m "Adding $Git_Ignore_File file based on standard"
		}
	}
}

function PushGitRepoToRemote() {
	Write-Host-Formatted "Pushing Git repo to remote ..."

	git remote add origin $Git_Repo
	git config --global push.default simple
	git push -u origin --all -v --progress

	# TODO: push in chunks
	# git rev-list --all --count
	# git rev-list master --first-parent --count
	# git push origin master~2500:refs/heads/master
	# git push origin master~2000:refs/heads/master
	# git push origin master~1500:refs/heads/master
	# git push origin master~1000:refs/heads/master
	# git push origin master~500:refs/heads/master
	# git push -u origin master
}

function GetTempDir() {
	Write-Host-Formatted "Creating temp dir ..."

	$ScriptName = Split-Path -Leaf $MyInvocation.ScriptName
	$TempDir = Join-Path $Env:Temp ($ScriptName + "-" + $pid + "-" + (Get-Random))
	if (Test-Path $TempDir) {
		throw "ERROR: cannot get unique temp dir: $TempDir"
	}

	New-Item $TempDir -Type directory | Out-Host

	Write-Host "Temp dir created: " $TempDir
	
	return $TempDir
}


#
# Main
#

if (! $Local_Git_Dir) {
	$Local_Git_Dir = GetTempDir
}

InitGitRepoLinkedToTFS

pushd $Local_Git_Dir

FetchAllChangesetsAndConvertToCommits

CleanupGitRepo

# TODO: Add a .gitattributes file
Provide_Gitignore_Files


# TODO: create repo first

# git repack -adf
# # Without this further push might fail.
# # It repacks git repo into a single pack, cleaning objects left after "git prune".
# # Might not be compatible with incremental push, or inefficient, as every push will send the whole pack every time.
# # Consider splitting pack: --max-pack-size=20m
# # Need further investigation and testing.
# # run this to check for issues: git fsck --full --dangling


PushGitRepoToRemote

# TODO: lock TFS, so no more changes can be checked in there

popd


if ($Remove_Local_Git_Dir) {
	Remove-Item $Local_Git_Dir -Recurse
}

Write-Host-Formatted "All done!"
