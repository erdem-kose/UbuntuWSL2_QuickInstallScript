$UbuntuLink='https://aka.ms/wslubuntu2004'
$UbuntuDownloadedFile='Ubuntu.appx'

# Enter Current Direction
cd $PSScriptRoot
cd ..
cd "Downloads"
$CurrentPath=Get-Location
$CurrentPath=$CurrentPath.Path

# Check if Windows Version is Suitable
$WinVer=[System.Environment]::OSVersion.Version.Build
if ($WinVer -le 18916){
	echo "Your Windows version is less than 18917, please update!"
	pause
	exit
}

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

if (!(Test-Path $UbuntuDownloadedFile)) {
	pause
  Invoke-WebRequest -Uri $UbuntuLink -OutFile $UbuntuDownloadedFile -UseBasicParsing #Download Ubuntu
}

# Remove Existing Version and Install New Ubuntu
Get-AppxPackage *Ubuntu* | Remove-AppxPackage
Add-AppxPackage .\Ubuntu.appx

# Create Shortcut
$UbuntuPackage = Get-AppxPackage -Name *Ubuntu*
$UbuntuPath=$UbuntuPackage.InstallLocation

$UbuntuPathChild= Get-ChildItem -Path $UbuntuPath -Include *.exe -File -Recurse -ErrorAction SilentlyContinue
$UbuntuExe=$UbuntuPathChild.Name
$UbuntuExePath=$UbuntuPath+"\"+$UbuntuExe

cd ..
$CurrentPath=Get-Location
$CurrentPath=$CurrentPath.Path

$WSHshell = New-Object -ComObject WScript.Shell
$ShortCut = $WSHshell.CreateShortcut($CurrentPath+"\ubuntu.lnk") 
$ShortCut.TargetPath = $UbuntuExePath
$ShortCut.Save() 
   
# Start Ubuntu
Start-Process -FilePath $UbuntuExePath
