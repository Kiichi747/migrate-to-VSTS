Param(
    [Parameter(Mandatory=$True)]
    [int] $ReleaseId,
	
    [Parameter(Mandatory=$False)]
    [string] $BranchThatTriggersRelease = "refs/heads/master"
)

#
# Constants
#
$ErrorActionPreference = "Stop"

$collectionuri = $Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$buildid = $Env:BUILD_BUILDID
$project = $Env:SYSTEM_TEAMPROJECT
$token = $Env:SYSTEM_ACCESSTOKEN
$builddef = $Env:BUILD_DEFINITIONNAME
$buildnum = $Env:BUILD_BUILDID
$branch = $Env:BUILD_SOURCEBRANCH


#
# Main
#

gci Env: | Out-Host

if ($branch -ne $BranchThatTriggersRelease) {
    Write-Host "Branch is: $branch, it's not $BranchThatTriggersRelease, so no release triggered"
	Exit
}

if (-not $token) {
	throw "ERROR: SYSTEM_ACCESSTOKEN is not defined. Make sure you enabled 'Allow Scripts to Access OAuth Token' in Options of this Build definition"
}

#Generate API URL
$account = "";
$reg = "^https://+(?<acc>[\w-]+?).visualstudio.com/$"
if ($collectionuri -match $reg) {
    $account = $Matches.acc
} else {
    throw "Failed to get the account name from collection url: " + $collectionuri
}
$url = "https://" + $account + ".vsrm.visualstudio.com/"+ $project + "/_apis/release/releases?api-version=3.0-preview.2"
Write-Host "Using the following URL to trigger the Release via VSTS API: $url"

#Generate Auth info
$basicAuth = ("{0}:{1}"-f "anys", $token)
$basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
$basicAuth = [System.Convert]::ToBase64String($basicAuth)
$headers = @{Authorization=("Basic {0}"-f $basicAuth)}

#Generate body content
$instanceRef = @{id = $buildID};
$artif = @{alias = $builddef; instanceReference = @{id = $buildnum}}
$content = @{
    definitionId = $ReleaseId
    description = "Triggered from CI Build"
    artifacts = @($artif)
    }
$json = $content | ConvertTo-Json -Depth 100

#Call Rest API to start the release
$responseBuild = Invoke-RestMethod -Uri $url -Method Post -Body $json -ContentType "application/json" -headers $headers
$responseBuild | Out-Host

if ($responseBuild.status -ne 'active') {
	throw "ERROR: doesnt look like Release has been successfully triggered"
}

Write-Host "Triggered release with id:" $responseBuild.id "and name:" $responseBuild.name
