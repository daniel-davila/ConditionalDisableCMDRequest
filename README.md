# About ConditionalDisableCMDRequest


I'm a Design Architect for Dell and one of my roles is supporting customers leveraging Microsoft's Autopilot provisioning with Intune. 
One of the main issues with troubleshooting pre-provisioning projects is customers may decide to implement the C:\Windows\Setup\Scripts\DisableCMDRequest.tag file to disable Shift+F10 invocation to display an elevated Command Prompt.

This project was created to allow for technicians pre-provisioning devices to pull logs on failures, but also ensure customers have a method to know the tag file is written when Pre-provisioning was successful. Once the file is created at the end of pre-provisioning the keyboard shortcut will be disabled on the next system boot, which is when the device is firat available to a user.

Historical information can be found here for reference:
(https://oofhours.com/2020/08/04/disable-shift-f10-in-oobe/)



## Usage

The code is fairly simple, to use it download the intunewin file (or compile from the PS1 file) and upload to your tenant as Win32 Application (this is the link in the console: https://endpoint.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsWindowsMenu/~/windowsApps

Once there, configure as follows and assign it to any group you currently use for Autopilot deployments. 

Install command: 
  powershell.exe -noprofile -executionpolicy bypass -file .\DisableCMDRequestPre-ProvTask.ps1

Uninstall command:
  cmd /c del %Windir%\Setup\Scripts\DisableCMDRequest.flg && del %ProgramData%\Microsoft\IntuneManagementExtension\Logs\DisableCMDRequestPre-ProvTask.flg

Install Behavior: 
  System

Device Restart Behavior:
  No specific action

Detection Rule Path: 
  %ProgramData%\Microsoft\IntuneManagementExtension\Logs

Detection Rule File:
  DisableCMDRequestPre-ProvTask.flg

Detection Method: 
  File Exists


## Support

This script is provided as-is, read the DisableCMDRequestPre-ProvTask.ps1 script code and adjust as necessary, but be careful not to add extra processing of tasks because even though it only takes 3 seconds to trigger on a successful screen, it runs silently in background. Any additional tasks you add won't be guaranteed before a technician selects RESEAL.
Use at your own risk.
