
@rem
@rem PREREQS: none
@rem USAGE: Run as local admin
@rem


@rem TODO: recognize if running without local admin rights

@rem Install Chocolatey (as described: https://chocolatey.org/install)
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

@rem Install Git
@rem choco install git -y

@rem Install GitTFS
choco install gittfs -y --allowEmptyChecksums

@rem Install VS
@rem choco install visualstudio2015community


@rem Check what's installed
@rem choco list -l


@rem TODO: Install Git Credentials Manager
@rem https://github.com/Microsoft/Git-Credential-Manager-for-Windows/releases/latest

choco install bfg-repo-cleaner -y
