$ubuntulink='https://aka.ms/wslubuntu2004'
$ubuntudownloadedfile='Ubuntu.appx'

#Enter Current Direction
cd $PSScriptRoot

#Settings For Elevated Process
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}
Set-ExecutionPolicy RemoteSigned

# Enable VirtualMachinePlatform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 

# Enabling Windows Subsystem Linux(WSL)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux 

# Enable WSL 2
wsl --set-default-version 2 

if (!(Test-Path $ubuntudownloadedfile)) {
	pause
  Invoke-WebRequest -Uri $ubuntulink -OutFile $ubuntudownloadedfile -UseBasicParsing #Download Ubuntu
}

#Remove and Install Ubuntu
Get-AppxPackage *Ubuntu* | Remove-AppxPackage
Add-AppxPackage .\Ubuntu.appx

#Start Ubuntu
$UbuntuPackage = Get-AppxPackage -Name *Ubuntu*
$UbuntuPath=$UbuntuPackage.InstallLocation

$UbuntuPathChild= Get-ChildItem -Path $UbuntuPath -Include *.exe -File -Recurse -ErrorAction SilentlyContinue
$UbuntuExe=$UbuntuPathChild.Name

Start-Process -FilePath $UbuntuPath"\"$UbuntuExe