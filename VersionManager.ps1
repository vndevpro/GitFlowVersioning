#################################
# This script contains funtions to create git tags following GitFlow
#################################

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
	
	if ($Prefix -ne "")
	{
		return $Prefix + "-" + (Get-Date).ToString("yyMMddhhmmss")
	}
	
	return (Get-Date).ToString("yyMMddhhmmss")
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
