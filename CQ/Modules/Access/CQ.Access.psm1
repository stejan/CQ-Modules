	
function Add-CQUser
{
	<#
	.SYNOPSIS
		Add a user to cq.
	.DESCRIPTION
		Creates an user on the cq instance.
	.PARAMETER userID
		Users ID
	.PARAMETER password
		Users new password
	.PARAMETER email
		Users email address
	.PARAMETER password
		Users new password
	.PARAMETER firstname
		Users firstname
	.PARAMETER lastname
		Users lastname
	.PARAMETER userFolder
		Folder to store the user. 
		E.g. test stores the user under /home/users/test
	.PARAMETER cqObject
		Object with the data of the cq instance.
	.EXAMPLE
		[ps] c:\foo> Add-CQUser -userID "test" -password "test" -email "jan.stettler@axpo.com" -givenName "GivenName" -familyName "FamilyName" -userFolder test -cqObject $cqObject
	#>
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[Parameter(Mandatory=$true)]
		[String]$userID,
	
		[Parameter(Mandatory=$true)]
		[String]$password,
	
		[Parameter(Mandatory=$true)]
		[String]$email,
	
		[Parameter(Mandatory=$false)]
		[String]$firstname = "",
	
		[Parameter(Mandatory=$false)]
		[String]$lastname = "",
	
		[Parameter(Mandatory=$false)]
		[String]$userFolder = "",
	
		[Parameter(Mandatory=$true)]
		[alias("cq")]
		[PSObject]$cqObject
	)
	
	$dataValues = @("_charset_=utf-8",
		":status=browser",
		"rep:userId=${userID}",
		"rep:password=${password}",
		"givenName=${givenName}",
		"familyName=${familyName}",
		"email=${email}",
		"intermediatePath=$userFolder"
	)
	$data = ConcatData $dataValues
	
	doCURL $cqObject.authorizables $cqObject.auth $data
}

function Add-CQGroup
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
	
		[Parameter(Mandatory=$true)]
		[String]$groupName,
	
		[Parameter(Mandatory=$false)]
		[String]$givenName = "",
	
		[Parameter(Mandatory=$false)]
		[String]$aboutMe = "",
	
		[Parameter(Mandatory=$false)]
		[String]$groupFolder = "",
	
		[Parameter(Mandatory=$true)]
		[alias("cq")]
		[PSObject]$cqObject
	)
	
	$dataValues = @("_charset_=utf-8",
		":status=browser",
		"groupName=${groupName}",
		"givenName=${givenName}",
		"aboutMe=${aboutMe}",
		"intermediatePath=${groupFolder}"
	)
	$data = ConcatData $dataValues
	
	doCURL $cqObject.authorizables $cqObject.auth $data
	
	$group = New-Object psobject -property @{
		groupName=${groupName} ;
		givenName=${givenName};
		aboutMe=${aboutMe};
		path="/home/groups/${groupFolder}";
	}
	return $group | Select groupName, givenName, aboutMe, path
}

function Add-CQMemberToGroup
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
	
		[Parameter(Mandatory=$true)]
		[String]$groupPath,
	
		[Parameter(Mandatory=$true)]
		[array]$memberEntries,
	
		[Parameter(Mandatory=$true)]
		[alias("cq")]
		[PSObject]$cqObject
	)
	
	$url = $cqObject.url+"$groupPath"
	
	$dataValues = @("_charset_=utf-8",
		"memberAction=memberOf"
	)
	$data = ConcatData $dataValues
	$data = $data + "&memberEntry=" + [system.String]::Join("&memberEntry=", $memberEntries)
	
	doCURL $url $cqObject.auth $data
}

function Add-CQRights
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
	
		[Parameter(Mandatory=$true)]
		[String]$authorizableId,
	
		[Parameter(Mandatory=$true)]
		[String]$path,
	
		[Parameter(Mandatory=$false)]
		[String]$read = "false",
	
		[Parameter(Mandatory=$false)]
		[String]$modify = "false",
	
		[Parameter(Mandatory=$false)]
		[String]$create = "false",
	
		[Parameter(Mandatory=$false)]
		[String]$delete = "false",
	
		[Parameter(Mandatory=$false)]
		[String]$acl_read = "false",
	
		[Parameter(Mandatory=$false)]
		[String]$acl_edit = "false",
	
		[Parameter(Mandatory=$false)]
		[String]$replicate = "false",
	
		[Parameter(Mandatory=$true)]
		[alias("cq")]
		[PSObject]$cqObject
	)
	
	$rightData = @("path:$path",
		"read:${read}",
		"modify:${modify}",
		"create:${create}",
		"delete:${delete}",
		"acl_read:${acl_read}",
		"acl_edit:${acl_edit}",
		"replicate:${replicate}"
	)
	$changelog = ConcatData $rightData ","
	
	$dataValues = @("authorizableId=$authorizableId",
		"changelog=$changelog"
	)
	
	$data = ConcatData $dataValues
	
	doCURL $cqObject.cqactions $cqObject.auth $data
}

function Add-CQFullRights
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
	
		[Parameter(Mandatory=$true)]
		[String]$authorizableId,
	
		[Parameter(Mandatory=$true)]
		[String]$path,
	
		[Parameter(Mandatory=$true)]
		[alias("cq")]
		[PSObject]$cqObject
	)
	
	Add-CQRights -authorizableId $authorizableId -path $path -read $true -modify $true -create $true -delete $true -acl_read $true -acl_edit $true -replicate $true -cqObject $cqObject
}

function Add-CQGroupWithRights
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[Parameter(Mandatory=$true)]
		[String]$mandantName,
	
		[Parameter(Mandatory=$true)]
		[String]$groupName,
	
		[Parameter(Mandatory=$false)]
		[String]$givenName = "",
	
		[Parameter(Mandatory=$false)]
		[String]$aboutMe = "",
	
		[Parameter(Mandatory=$false)]
		[array]$memberOf = @(),
	
		[Parameter(Mandatory=$false)]
		[array]$contentPaths = @(),
	
		[Parameter(Mandatory=$true)]
		[alias("cq")]
		[PSObject]$cqObject
	)
	
	Add-CQGroup -groupName $groupName -givenName $givenName -groupFolder ${mandantName} -cq $cqObject
	Add-CQMemberToGroup "/home/groups/${mandantName}/$groupName" $memberOf -cq $cqObject
	foreach ($contentPath in $contentPaths)
	{
		Add-CQRights -authorizableId "$groupName" -path $contentPath -read $true -cq $cqObject
	}
}