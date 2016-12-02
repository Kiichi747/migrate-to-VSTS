#
# Assumptions:
# - running on Windows machine
#
# Based on: https://git-scm.com/docs/gitattributes#_end_of_line_conversion
#

#
# Constants
#
$ErrorActionPreference = "Stop"
$gitattributes = '.gitattributes'


#
# Functions
#
function CheckWeAreInTheGitRepo() {
	if (! (Test-Path '.git' -PathType Container)) {
		throw "Current dir doesn't look like a root folder of Git repo"
	}
}

function CheckThereAreNoUncommittedChangesExceptEOLs() {
	# TODO: allow spontaneous changes in line endings due to them being incorrect in the repo, try: --ignore-space-at-eol
	git diff-index --quiet HEAD
	if ($?) {
		Write-Host "No uncommitted changes detected"
	} else {
		throw "ERROR: there are pending changes in the repo, commit or undo them first"
	}
}

function UpdateGitAttributesFile() {
	$addition       = '* text=auto'
	$addition_regex = "^\s*\*\s+text=auto"
	if ((Test-Path $gitattributes -PathType Leaf) -and ((gc $gitattributes) -match $addition_regex)) {
		Write-Host "$gitattributes already contains line for $addition"
	} else {
		Write-Host "Adding line to $gitattributes : $addition"
		$addition >> $gitattributes
	}
}

function Normalize() {
	# TODO: introduce checks below after each command
	
	del .git\index    # Remove the index to force Git to
	git reset         # re-scan the working directory
	git status        # Show files that will be normalized
	git add -u
	git add $gitattributes
	git commit -m "Introduce end-of-line normalization"
}


#
# Main programme
#

CheckWeAreInTheGitRepo

CheckThereAreNoUncommittedChangesExceptEOLs

UpdateGitAttributesFile

Normalize
