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

function GetListOfWorkItems([string]$collectionuri, $headers, [string] $WorkItemType) {
	# https://www.visualstudio.com/en-us/docs/integrate/api/wit/wiql#a-flat-query

	# Generate API URL
	$url = $collectionuri + 'DefaultCollection/_apis/wit/wiql?api-version=1.0'

	# Generate body
	$WIQL_query = "Select [System.Id], [System.Title], [System.State] From WorkItems Where [System.WorkItemType] = '" + $WorkItemType + "' AND [State] = 'Closed' order by [Microsoft.VSTS.Common.Priority] asc, [System.CreatedDate] desc"
	Write-Verbose "Running query: $WIQL_query"

	$body = @{ query = $WIQL_query }
	$bodyJson=@($body) | ConvertTo-Json

	# Call API to get list of team projects
	$response = Invoke-RestMethod -Uri $url -headers $headers -Method Post -ContentType "application/json" -Body $bodyJson

	return @($response.workItems)
}


#
# Main
#

$collectionuri = GetCollectionURI

$token = GetAccessToken
$headers = GenerateAuthInfo $token

$WorkItemType = 'User Story'

$workitems = GetListOfWorkItems $collectionuri $headers $WorkItemType

Write-Host "Found" $workitems.Count "work items of type:" $WorkItemType
