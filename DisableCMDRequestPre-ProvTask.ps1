<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.209
	 Created on:   	1/25/2023 4:18 PM
	 Created by:   	Daniel_Davila
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A method to create a scheduled task on Autopilot Success which writes C:\Windows\Setup\Scripts\DisableCmdRequest.tag file on successful pre-provisioning.
		This allows Command Prompt window access for troubleshooting log collection

		WARNING: The configured scheduled task is meant to run a command quickly as possible. Do not configure addtional tasks otherwise execution will be delayed.
#>

$logName = $($((Split-Path $MyInvocation.MyCommand.Definition -leaf)).replace("ps1", "log"))
$logPath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logFile = "$logPath\$logName"
$flagFile = $($((Split-Path $MyInvocation.MyCommand.Definition -leaf)).replace("ps1", "flg"))
$TaskName = "DisableCmdRequest"
$TaskPath = "\CustomAutopilotTrigger\"

$scriptpath = "$env:windir\Temp\Scripts"
if (!(Test-Path $scriptpath)) { New-Item -Path $scriptpath -ItemType Directory }

Start-Transcript $logFile -Append -Force

$XMLContents = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2022-03-09T09:01:07.4323443</Date>
    <Author>DellDevice\defaultuser0</Author>
    <URI>\CustomAutopilotTrigger\DisableCmdRequest</URI>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-Shell-Core/Operational"&gt;&lt;Select Path="Microsoft-Windows-Shell-Core/Operational"&gt;*[System[(Level=4 or Level=0) and (EventID=62407)]]
and
*[EventData[Data[@Name="Value"] = "AutopilotWhiteGlove: showing success page because AutopilotWhiteGloveSuccess was marked as success."]]
&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-command "&amp; {if (!(Test-Path "$env:windir\Setup\Scripts\DisableCMDRequest.TAG")) { New-Item "$env:windir\Setup\Scripts\DisableCMDRequest.TAG" -Force}}"</Arguments>
    </Exec>
  </Actions>
</Task>
'@

Register-ScheduledTask -xml ($XMLContents | Out-String) -TaskName $TaskName -TaskPath $TaskPath -User SYSTEM -Force

$check = Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue
if ($check)
{
	Write-Host "Success: Scheduled task was CONFIRMED!"
	Write-Host "Writing to "$logPath\$flagFile""
	Set-Content -Path "$logPath\$flagFile" -Value "Scheduled task $TaskName has been confirmed"
}
else
{
	Write-Host "Error: Scheduled task WAS NOT CONFIRMED!"
	exit 3
}

Stop-Transcript