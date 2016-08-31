

function ProcessRepoDir($git_repo_dir) {
	Write-Host "--- Updating $git_repo_dir"
	pushd $git_repo_dir

	git pull --rebase
	if (! $?) {
		throw "ERROR: pull command failed with exit code: $LASTEXITCODE"
	}

	git push
	if (! $?) {
		throw "ERROR: push command failed with exit code: $LASTEXITCODE"
	}

	popd
}

function ProcessDir($dir) {
	gci $dir | ? {($_.PSIsContainer)} | %{
		$curdir = $_.FullName
		if (Test-Path $curdir\.git) {
			ProcessRepoDir $curdir
		} else {
			Write-host "$curdir - doesn't look like a Git repo"
			ProcessDir $curdir
		}
	}
}

ProcessDir .
