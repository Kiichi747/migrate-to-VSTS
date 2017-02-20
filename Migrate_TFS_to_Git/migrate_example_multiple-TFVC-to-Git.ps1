
$ErrorActionPreference = "Stop"

$ProjectsMapping = @{
	'$/Core/Common/Trunk' = 'Core.Common';
	'$/Core/TestHarness/Trunk' = 'Core.TestHarness'
}


$ProjectsMapping.Keys | %{
	$TFS_Path = $_
	$VSTS_ShortName = $ProjectsMapping.$TFS_Path
	
	Write-Host "Migrating: $TFS_Path to $VSTS_ShortName" -ForegroundColor black -BackgroundColor yellow
	
	.\migrate.ps1 `
		-TFS_Collection_URL:'http://<TFS-SERVER-ADDRESS>:8080/tfs/DefaultCollection' `
		-TFS_Path:$TFS_Path `
		-Local_Git_Dir:"C:\S\Git_migration\$VSTS_ShortName" `
		-Git_Author:'FirstName LastName <my-email@address.com>' `
		-Git_Repo:"https://<ACCOUNT>.visualstudio.com/DefaultCollection/<PROJECT>/_git/$VSTS_ShortName" `
		-Provide_Gitignore_Files:$False `
		-PushGitRepoToRemote:$True `
		-Remove_Local_Git_Dir:$False
}
