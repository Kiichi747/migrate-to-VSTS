
# Installation of TFS Integration Tools inside Windows VM based on Oracle Virtual Box

<!--
TFSIntegrationTools has following prerequisites:
- .NET Framework 3.5 SP1
- Team Explorer (TE 2008, 2010 or Dev11), to use with VSTS only Dev11 (2012) will work
- SQL Server Express 2012 (some other older versions are supported too)
-->

## Download all installers

**Note**: Store all downloaded files in this directory as it will be later mounted to VM.

* Download .NET Framwork 3.5 SP1 from https://www.microsoft.com/en-gb/download/details.aspx?id=25150
<!-- newer Windows versions will not have it, so have to install it -->
* Download Team Explorer for Microsoft Visual Studio 2012: https://www.microsoft.com/en-gb/download/details.aspx?id=30656
<!--
Team Explorer 2010: https://download.microsoft.com/download/4/4/C/44CD7FE1-CA53-441C-863C-F7E78F24D092/VS2010TE1.iso
or: https://tfsintegration.codeplex.com/downloads/get/364478# 
-->

* Download SQL Server 2012 Express (SQLEXPR_x64_ENU.exe) from https://www.microsoft.com/en-gb/download/details.aspx?id=29062
* Download TFSIntegrationTools.msi from https://visualstudiogallery.msdn.microsoft.com/eb77e739-c98c-4e36-9ead-fa115b27fefe/file/68615/1/TFSIntegrationTools.msi


## Install VirtualBox and Vagrant

* Run **cmd.exe** as Administrator
* Install Chocolatey as described in: https://chocolatey.org/install by running:
`@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"`
* Install 7zip: `choco install 7zip`
* Extract VS2012_TEAMEXP_MSDN_enu.iso using 7zip
* Install VirtualBox: `choco install virtualbox`
* Fix VirtualBox path in user env var PATH as choco installation sets it incorrectly
* \[Optional\] Change default machine folder of VirtualBox:
	- to check current setting, run: `VBoxManage list systemproperties | findstr /C:"Default machine folder"`
	- to change it run: `VBoxManage setproperty machinefolder <dir>`
* \[Optional\] Specify VAGRANT_HOME where all the downloaded boxes will be stored by running: `setx VAGRANT_HOME D:\.vagrant.d`
* Restart cmd.exe to use updated environment variables
* Install Vagrant: `choco install vagrant -y --allowEmptyChecksums`


## Create VM

* Review Vagrant file that contains all required settings
* Run VM: `vagrant up`
* Login to VM using standard username and password: *vagrant*


## Run Inside VM

<!-- create snapshots in VirtualBox between all important steps, so you can always go back -->
* Open C:\vagrant folder mapped from host, where you can find all downloaded installers
* Install Team Explorer 2012 by running setup.exe in the extracted VS2012_TEAMEXP_MSDN_enu.iso
* Install SQL Server 2012 Express
* Install .NET Framwork 3.5 SP1
* Install TFSIntegrationTools.msi, specifying:
	- Enable checkbox to install TFS Integration Service
	- TF Integration service to run as user `vagrant` with password `vagrant`
	- Database Information \ Server Name: `localhost\SQLEXPRESS`
* Run TFS Integration Tools and configure both TFS\VSTS sources, for example:
	- https://<ACCOUNT>.visualstudio.com
	- http://<SERVER>:8080/tfs/
