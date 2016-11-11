
$VerbosePreference = "Stop"

$tfsSource="http://<server>:8080/tfs/DefaultCollection";
$tpSource="<project_name>";

$tfsDest="https://<account>.visualstudio.com/DefaultCollection";
$tpDest="Sandbox";


[Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.Client')
[Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.TestManagement.Client')

$sourceTpc = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tfsSource)
$sourceTcm = $sourceTpc.GetService([Microsoft.TeamFoundation.TestManagement.Client.ITestManagementService])
$sourceProject = $sourceTcm.GetTeamProject($tpSource);
$sourceTestCases = $sourceProject.TestCases.Query("SELECT * FROM WorkItem");

$destTpc = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tfsDest)
$destTcm = $destTpc.GetService([Microsoft.TeamFoundation.TestManagement.Client.ITestManagementService])
$destProject = $destTcm.GetTeamProject($tpDest);


foreach ($tc in $sourceTestCases)
{
    Write-Host ("Copying Test Case {0} - {1}" -f $tc.Id, $tc.Title)
    $destTestCase = $destProject.TestCases.Create();
    $destTestCase.Title = $tc.Title;
    $destTestCase.Priority = $tc.Priority;

    foreach ($step in $tc.Actions)
    {
        $destStep= $destTestCase.CreateTestStep();

        $destStep.Title = $step.Title
        $destStep.TestStepType = $step.TestStepType
        $destStep.Description = $step.Description
        $destStep.ExpectedResult =  $step.ExpectedResult;
        $destTestCase.Actions.Add($destStep);
    }
    $destTestCase.Save();
}
