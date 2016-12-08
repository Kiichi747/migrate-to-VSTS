[CmdletBinding()]
Param ()


#
# Constants
#
$ErrorActionPreference = "Stop"


#
# Variables
#
$stats_branch_builds = @{}
$stats_repos
$stats_branches


#
# Functions
#
function GetCollectionURI() {
	$collectionuri = $Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
	if (-not $collectionuri) {
		throw "ERROR: SYSTEM_TEAMFOUNDATIONCOLLECTIONURI is not defined."
	}
	return $collectionuri
}

function GetAccessToken() {
	$token = $Env:SYSTEM_ACCESSTOKEN
	if (-not $token) {
		throw "ERROR: SYSTEM_ACCESSTOKEN is not defined. Make sure you enabled 'Allow Scripts to Access OAuth Token' in Options of this Build definition."
	}
	return $token
}

function GenerateAuthInfo([string] $token) {
	$basicAuth = ("{0}:{1}"-f "anys", $token)
	$basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
	$basicAuth = [System.Convert]::ToBase64String($basicAuth)
	$headers = @{Authorization=("Basic {0}"-f $basicAuth)}
	return $headers
}

function GetListOfTeamProjects([string]$collectionuri, $headers) {
	# https://www.visualstudio.com/en-us/docs/integrate/api/tfs/projects#get-a-list-of-team-projects

	# Generate API URL
	$url = $collectionuri + 'DefaultCollection/_apis/projects?api-version=1.0'

	# Call API to get list of team projects
	$response = Invoke-RestMethod -Uri $url -headers $headers
	if ($response.count -lt 1) {
		$response | Out-Host
		throw "ERROR: cannot get list of team projects"
	}

	return @($response.value | %{$_.name})
}

function GetListOfGitRepos([string] $project) {
	# https://www.visualstudio.com/en-us/docs/integrate/api/git/repositories#get-a-list-of-repositories

	# Generate API URL
	$url = $collectionuri + 'DefaultCollection/' + $project + '/_apis/git/repositories?api-version=1.0'

	# Call API to get list of repos
	$response = Invoke-RestMethod -Uri $url -headers $headers

	return @($response.value | %{$_.name})
}

function GetListOfRefs([string] $project, [string] $repo) {
	# https://www.visualstudio.com/en-us/docs/integrate/api/git/refs#just-branches

	# Generate API URL
	$url = $collectionuri + 'DefaultCollection/' + $project + '/_apis/git/repositories/' + $repo + '/refs/heads?api-version=1.0&includeStatuses=true'

	# Call API to get list of refs heads
	$response = Invoke-RestMethod -Uri $url -headers $headers

	return @($response.value)
}


#
# Main
#

$collectionuri = GetCollectionURI

$token = GetAccessToken
$headers = GenerateAuthInfo $token

$projects = GetListOfTeamProjects $collectionuri $headers

ForEach ($project in $projects)
{
	Write-Host "Project:" $project
	$repos = GetListOfGitRepos $project
	$stats_repos += $repos.Count
	ForEach ($repo in $repos)
	{
		Write-Host "`tRepo:" $repo
		$refs = GetListOfRefs $project $repo
		$stats_branches += $refs.Count
		# TODO: flag too many branches per repo, e.g. more than 10
		ForEach ($branch in $refs)
		{
			if ($branch.statuses.Count -gt 0) {
				$build = $branch.statuses[0] # first record seems to be the most recent build record
				$buildState = $build.state
				# TODO: analyze also $build.creationDate
				# TODO: flag if latest code is not built
			} else {
				$buildState = 'not built'
			}
			$stats_branch_builds.$buildState++
			Write-Host "`t`tBranch:" $branch.name ", build state:" $buildState
			# TODO: get aheadCount and behindCount and flag if they are too big: https://www.visualstudio.com/en-us/docs/integrate/api/git/stats#a-branch
			# TODO: using one call per repo should be faster: https://www.visualstudio.com/en-us/docs/integrate/api/git/stats#all-branches
		}
	}
}
# TODO: check master is protected by Branch Policies, especially require PRs to be successfully built to merge to master:
# https://www.visualstudio.com/en-us/docs/integrate/api/policy/types
# https://www.visualstudio.com/en-us/docs/integrate/api/policy/configurations

# TODO: check master won't allow force push (Rewrite history permission set to Deny for Contributors)

# TODO: flag long living branchs, e.g. older than 7 days

Write-Host
Write-Host "=== Statistics: team projects"
Write-Host "`ttotal = " $projects.Count

Write-Host "=== Statistics: Git repositories"
Write-Host "`ttotal = " $stats_repos
Write-Host "`taverage repos per project = " ($stats_repos / $projects.Count)

Write-Host "=== Statistics: branches:"
Write-Host "`ttotal = " $stats_branches
Write-Host "`taverage branches per repo = " ($stats_branches / $stats_repos)

Write-Host "=== Statistics: branch builds:"
$stats_branch_builds | Out-Host
