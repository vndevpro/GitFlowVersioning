#################################
# This script contains funtions to create git tags following GitFlow
#################################
function New-Tag
{
	param (
        [Parameter(Mandatory=$true)]
        [string]$Branch
    )
	
	$version = Get-CurrentVersion
	$patch = Get-NewPatch
	$prefix = ""
		
	if ($Branch -eq "release")
	{
		$version = ([decimal]$version + 0.1).ToString()
		$prefix = "Beta-"
	}
	if ($Branch -eq "develop")
	{
		$version = ([decimal]$version + 0.1).ToString()
		$prefix = "Dev-"
	}
	if ($Branch -eq "hotfix")
	{
		$prefix = "HF-"
	}
	
	$tag = "v$version.$prefix$patch"
	
	Invoke-Expression "git tag $tag"
	Invoke-Expression "git push origin $tag"
	
	return $tag
}

function Get-CurrentVersion
{	
	$tags = Get-GitTags
	
	if ($tags.Count -gt 0)
	{
		$major = 0; $minor = 1
		
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
		
		return "$major.$minor"
	}
	
	return "0.1"
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

function Get-NextVersion
{
	$currentVersion = Get-CurrentVersion
	return ([decimal]$currentVersion + 0.1).ToString()
}

function Get-GitTags
{
	$tags = Invoke-Expression "git tag --list"
	$tags
}