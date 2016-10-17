if ($env:BUILD_SOURCEBRANCHNAME -eq "master")
{
$collectionuri = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$buildid = $env:BUILD_BUILDID
$project = $env:SYSTEM_TEAMPROJECT
$token = $env:SYSTEM_ACCESSTOKEN
$builddef = $env:BUILD_DEFINITIONNAME
$buildnum = $env:BUILD_BUILDID
$releaseid = 2;

#Generate API URL
$account = "";
$reg = "https://+(?<acc>\w+?).visualstudio+"
if ($collectionuri -match $reg)
{
    $account = $Matches.acc;
}
else
{
    Write-Host "Fail to get the account name from collection url";
}
$url= "https://" + $account + ".vsrm.visualstudio.com/"+ $project + "/_apis/release/releases?api-version=3.0-preview.2"

#Generate Auth info
$basicAuth= ("{0}:{1}"-f "anys",$token)
$basicAuth=[System.Text.Encoding]::UTF8.GetBytes($basicAuth)
$basicAuth=[System.Convert]::ToBase64String($basicAuth)
$headers= @{Authorization=("Basic {0}"-f $basicAuth)}

#Generate body content
$instanceRef = @{id = $buildID};
$artif = @{alias = $builddef; instanceReference = @{id = $buildnum}}
$content = @{
    definitionId = $releaseid
    description = "Triggered from CI Build"
    artifacts = @($artif)
    }
$json = $content | ConvertTo-Json -Depth 100

#Call Rest API to start the release
$responseBuild = Invoke-RestMethod -Uri $url -headers $headers -Method Post -Body $json -ContentType "application/json"
}
else
{
    Write-Host "Not master branch, no release triggered"
}