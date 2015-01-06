# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "vagrant-w7-choco-bs"

  config.vm.box_check_update = false

  config.vm.communicator = "winrm"
  config.vm.guest = :windows

  config.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = "2048"
  end

shell_script = <<-SCRIPT

$installDir = "c:\\Users\\vagrant"
$ftp = "ftp://router-7.bring.out.ba/Main/files/Platform/"
$file = "cygwin-3.7z"
$file_qt = "Qt_54_mingw_win32.7z"
$file_hb = "harbour_core.tar.gz"
$file_java = "home_java.tar.gz"
$user = "ftpadmin"
Write-Host "U vagrant direktoriju se nalazi ftp_password.config"
$pass = Get-Content( "c:\\vagrant\\ftp_password.config" ) 
Write-Host "ftp pasword je: $pass"

$destCygwin = Join-Path $installDir $file
$destQt = Join-Path $installDir $file_qt
$destJava = Join-Path $installDir $file_java
$destHb = Join-Path $installDir $file_hb

[System.Console]::Writeline($ftp)
[System.Console]::Writeline($user)
[System.Console]::Writeline($file)
[System.Console]::Writeline($destCygwin)

$webclientFtp = New-Object System.Net.WebClient 
$webclientFtp.Credentials = New-Object System.Net.NetworkCredential($user,$pass)  

$uri = New-Object System.Uri($ftp + $file) 
[System.Console]::Writeline( "download: " + $uri)
$webclientFtp.DownloadFile($uri, $destCygwin)

$uri_qt = New-Object System.Uri($ftp + $file_qt) 
[System.Console]::Writeline( "download: " + $uri_qt)
$webclientFtp.DownloadFile($uri_qt, $destQt)

$uri_hb = New-Object System.Uri($ftp + $file_hb) 
[System.Console]::Writeline( "download: " + $uri_hb)
$webclientFtp.DownloadFile($uri_qt, $destHb)


$uri_java = New-Object System.Uri($ftp + $file_java) 
[System.Console]::Writeline( "download: " + $uri_java)
$webclientFtp.DownloadFile($uri_java, $destJava)


function Download-File {
param (
  [string]$url,
  [string]$file
 )

  [System.Console]::Writeline("Downloading $url to $file")

  $downloader = new-object System.Net.WebClient
  $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;
  $downloader.DownloadFile($url, $file)
}

[System.Console]::Writeline( "Download 7za from chocolatey")
$7zaExe = Join-Path $installDir '7za.exe'

Download-File 'https://chocolatey.org/7za.exe' "$7zaExe"


[System.Console]::Writeline( "Extract cygwin to " + $destCygwin)
Start-Process "$7zaExe" -ArgumentList "x -o`"c:\\`" -y `"$destCygwin`"" -Wait -NoNewWindow

[System.Console]::Writeline( "Extract qt to " + $destQt)
Start-Process "$7zaExe" -ArgumentList "x -o`"c:\\`" -y `"$destQt`"" -Wait -NoNewWindow


$script = "c:\\cygwin\\home\\vagrant\\script.sh"
$new_line = "`n"

[System.Console]::Writeline( "Generisem script za pokretanje HB build-a" )

$stream = [System.IO.StreamWriter] $script
$stream.Write("#!/bin/bash`n")
$stream.Write("tar xvfz /cygdrive/c/Users/vagrant/$file_java`n")
$stream.Write("rm /cygdrive/c/Users/vagrant/$file_java`n")
$stream.Write("mkdir hb`n")
$stream.Write("mkdir -p /cygdrive/Platform/HB`n")
$stream.Write("echo ``pwd```n")
$stream.Write("cd hb`n")
$stream.Write("tar xvfz /cygdrive/c/Users/vagrant/$file_hb`n")
$stream.Write("rm /cygdrive/c/Users/vagrant/$file_hb`n")

$stream.Write("git checkout -f`n")
$stream.Write("export PATH=/opt/lo/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:`$PATH`n")

$stream.Write("HB_INSTALL_PREFIX=c:\\Platform\\HB ./win-make.exe" + $new_line)

$stream.Write( "cd /cygdrive/c/Platform/HB" + $new_line)
$stream.Write( "zip -r HB_Platform.zip bin" + $new_line)
$stream.Write( "zip -r HB_Platform_sdk.zip include lib" + $new_line)

$file_server_user="root"
$file_server_host="files.bring.out.ba"
$file_server_path="/mnt/HD/HD_a2/bringout/Platform/win32"

$stream.Write( "cp /cygdrive/c/vagrant/hernad_ssh.key /home/vagrant/ssh.key" + $new_line )
$stream.Write( "chmod 0600 /home/vagrant/ssh.key" + $new_line )
$stream.Write( "export SSH_OPTS=`"-i /home/vagrant/ssh.key -o StrictHostKeyChecking=no`"" + $new_line)
$stream.Write( "scp `$SSH_OPTS HB_Platform*.zip $file_server_user@$file_server_host:$file_server_path" + $new_line)
$stream.Write( "ssh `$SSH_OPTS $file_server_user@$file_server_host chown hernad $file_server_path/HB_Platform*.zip" + $new_line)

$stream.close()

$command = @'
$env:Path = "c:\\cygwin\\bin;" + $env:Path
chdir c:\\cygwin\\home\\vagrant
bash script.sh
'@

Invoke-Expression -Command:$command


SCRIPT

  config.vm.provision "shell", inline: shell_script

end
