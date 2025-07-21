#################################
# This script VersionManagerCommon.ps1 contains funtions to create git tags following GitFlow
#################################
function New-Tag
{
	param (
        [Parameter(Mandatory=$true)]
        [string]$Branch,
		
		[Parameter(Mandatory=$false)]
        [string]$SourceBranch = ""		
    )
	
	$postfix = ""
	$version = Get-CurrentVersion
	
	Write-Host "Current version is: $version"
		
	# Release branch needs to increase version and add "-beta"
	if ($Branch -eq "release")
	{
		$version = ([decimal]$version + 0.1).ToString()
		$postfix = "-beta"
	}

	# Develop branch needs to increase version and add "-dev"
	if ($Branch -eq "develop")
	{
		$version = ([decimal]$version + 0.1).ToString()
		$postfix = "-dev"
	}
	
	# Hotfix branch just needs to add "-hf"
	if ($Branch -eq "hotfix")
	{
		$postfix = "-hf"
	}
	
	# Increase version if merge from "release" branch to "master" branch
	if ($Branch -eq "master" -and $SourceBranch -eq "release")
	{
		$version = ([decimal]$version + 0.1).ToString()
	}
		
	$patch = Get-NewPatch -Version $version
	Write-Host "New patch is: $patch"
	
	$tag = "v$version.$patch+$postfix"
	
	Invoke-Expression "git tag $tag"
	Invoke-Expression "git push origin $tag"
	
	return $tag
}

function Get-CurrentVersion
{	
	$major = 0; $minor = 1
	$tags = Invoke-Expression "git tag --list"
	
	if ($tags.Count -gt 0)
	{
		$pattern = '^v(\d+)\.(\d+)\.(\d+)$'

		foreach($tag in $tags)
		{
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

function Get-NextVersion
{	
	$major = 0; $minor = 1
	$tags = Invoke-Expression "git tag --list ""*-beta"""
	
	if ($tags.Count -gt 0)
	{
		$pattern = '^v(\d+)\.(\d+)\.(\d)(-beta)$'
		
		foreach($tag in $tags)
		{
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
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
	
	$major = 0; $minor = 1; $patch = 0
	$tags = Invoke-Expression "git tag --list ""v$Version.*"""	
	
	if ($tags.Count -gt 0)
	{
		$pattern = '^v(\d+)\.(\d+)\.(\d+)(.*)$'
		
		foreach($tag in $tags)
		{
			if ($tag -match $pattern)
			{
				if ($Matches[1] -gt $major)
				{
					$major = $Matches[1]
					$minor = $Matches[2]
					$patch = $Matches[3]
				}
				elseif ($Matches[1] -eq $major -and $Matches[2] -gt $minor)
				{
					$minor = $Matches[2]
					$patch = $Matches[3]
				}
			}
		}
	}
	
	return ($patch + 1)
}

Get-NewPatch