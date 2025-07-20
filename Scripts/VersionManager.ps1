#################################
# This script contains funtions to create git tags following GitFlow
#################################
function New-Tag
{
	param (
        [Parameter(Mandatory=$true)]
        [string]$Branch,
		
		[Parameter(Mandatory=$false)]
        [string]$SourceBranch = ""		
    )
	
	$version = Get-CurrentVersion
	$patch = Get-NewPatch
	$prefix = ""
	
	Write-Host "Current version is: $version And new patch is: $patch"
		
	# Release branch needs to increase version and add "Beta-" prefix
	if ($Branch -eq "release")
	{
		$version = ([decimal]$version + 0.1).ToString()
		$prefix = "Beta-"
	}

	# Develop branch needs to increase version and add "Dev-" prefix
	if ($Branch -eq "develop")
	{
		$version = ([decimal]$version + 0.1).ToString()
		$prefix = "Dev-"
	}
	
	# Hotfix branch just needs to add "HF-" prefix
	if ($Branch -eq "hotfix")
	{
		$prefix = "HF-"
	}
	
	# Increase version if merge from "release" branch to "master" branch
	if ($Branch -eq "master" -and $SourceBranch -eq "release")
	{
		$version = ([decimal]$version + 0.1).ToString()
	}
	
	$tag = "v$version.$prefix$patch"
	
	Invoke-Expression "git tag $tag"
	Invoke-Expression "git push origin $tag"
	
	return $tag
}

function Get-CurrentVersion
{	
	$major = 0; $minor = 1
	$tags = Get-GitTags
	
	if ($tags.Count -gt 0)
	{
		foreach($tag in $tags)
		{
			$pattern = '^v(\d+)\.(\d+)\.\d+$'
			if ($tag -match $pattern)
			{
				if ($Matches[1] -gt $major)
				{
					$major = $Matches[1]
					$minor = $Matches[2]
				}
				elseif ($Matches[1] -eq $major -and $Matches[2] -gt $minor)
				{
					$minor = $Matches[2]
				}
			}
		}
	}
	
	return "$major.$minor"
}

function Get-NewPatch
{
	param (
        [Parameter(Mandatory=$false)]
        [string]$Prefix = ""
    )
	
	if ($Prefix -eq "")
	{
		return (Get-Date).ToString("yyMMddhhmmss")
	}
	
	return $Prefix + "-" + (Get-Date).ToString("yyMMddhhmmss")
}

function Get-GitTags
{
	$tags = Invoke-Expression "git tag --list"
	$tags
}