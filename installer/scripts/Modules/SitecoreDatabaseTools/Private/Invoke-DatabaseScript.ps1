function Invoke-DatabaseScript {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		$Script,
		[string]$ResourcesPath,
		[Parameter(Mandatory=$true)]
		[string]$DatabaseServer,
		[string]$DatabaseName,
		[string]$DatabaseUserName,
		[string]$DatabasePassword,
		[hashtable]$variables
	)

	if (Test-Path $(Join-Path $ResourcesPath -ChildPath $Script.file))
	{
		$variables.GetEnumerator() | % { Set-Variable -Name $_.Key -Value $_.Value }

		Write-Host "Executing $($Script.file)..."
		$scriptContent = Get-Content $(Join-Path $ResourcesPath -ChildPath $Script.file) -Raw
		foreach ($textVariable in $Script.variables.text)
		{
			$members = $textVariable | Get-Member -View Extended
			foreach ($member in $members)
			{
				Write-Debug "Property: $($member.Name)"
				Write-Debug "Value: $($textVariable.$($member.Name))"
				$value = $ExecutionContext.InvokeCommand.ExpandString("$($textVariable.$($member.Name))")
				$scriptContent = $scriptContent.Replace($member.Name, $value)
			}
			Write-Debug $scriptContent
		}

		$sqlcommandVariables = @()
		foreach ($sqlcommandVariable in $Script.variables.sqlcommand)
		{
			$members = $sqlcommandVariable | Get-Member -View Extended
			foreach ($member in $members)
			{
				Write-Debug "Property: $($member.Name)"
				Write-Debug "Value: $($sqlcommandVariable.$($member.Name))"
				$sqlcommandVariables += "$($member.Name)=$ExecutionContext.InvokeCommand.ExpandString($($sqlcommandVariable.$($member.Name))"
			}
		}

		Invoke-Sqlcmd -Database $DatabaseName -ServerInstance $DatabaseServer -Username $DatabaseUserName -Password $DatabasePassword -OutputSqlErrors $true -Query $scriptContent -Variable $sqlcommandVariables
	}
}