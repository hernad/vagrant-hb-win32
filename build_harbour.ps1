function Download-File {
 param (
  [string]$url,
  [string]$file
 )

 if (Test-Path $file) {
   [System.Console]::Writeline("Downloading $url to $file")
   $downloader = new-object System.Net.WebClient
   $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;
   $downloader.DownloadFile($url, $file)
 }
 else {
    [System.Console]::Writeline("File already exists: $file")
 }

}


$installDir = "c:\Users\vagrant"
$ftp = "ftp://router-7.bring.out.ba/Main/files/Platform/"
$ftp_win32 = "ftp://router-7.bring.out.ba/Main/files/Platform/win32/"

$file = "cygwin-3.7z"
$file_qt = "Qt_54_mingw_win32.7z"
$file_hb = "harbour_core.tar.gz"
$file_java = "home_java.tar.gz"
$file_psql = "PSQL_Platform.zip"


$user = "ftpadmin"
Write-Host "U vagrant direktoriju se nalazi ftp_password.config"
$pass = Get-Content( "c:\vagrant\ftp_password.config" )
Write-Host "ftp pasword je: $pass"

$destCygwin = Join-Path $installDir $file
$destQt = Join-Path $installDir $file_qt
$destJava = Join-Path $installDir $file_java
$destHb = Join-Path $installDir $file_hb
$destPSQL = Join-Path $installDir $file_psql

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
$webclientFtp.DownloadFile($uri_hb, $destHb)


$uri_java = New-Object System.Uri($ftp + $file_java)
[System.Console]::Writeline( "download: " + $uri_java)
$webclientFtp.DownloadFile($uri_java, $destJava)

$uri_psql = New-Object System.Uri($ftp_win32 + $file_psql )
[System.Console]::Writeline( "download: " + $uri_psql)
$webclientFtp.DownloadFile($uri_psql, $destPSQL )


[System.Console]::Writeline( "Download 7za from chocolatey")
$S7zaExe = Join-Path $installDir '7za.exe'

Download-File 'https://chocolatey.org/7za.exe' "$S7zaExe"


$file_present = Test-Path "c:\cygwin"
if (! $file_present) {
 [System.Console]::Writeline( "Extract cygwin to " + $destCygwin)
 Start-Process "$S7zaExe" -ArgumentList "x -o`"c:\`" -y `"$destCygwin`"" -Wait -NoNewWindow
}

$file_present = Test-Path "c:\Qt"
if (! $file_present) {
  [System.Console]::Writeline( "Extract qt to " + $destQt)
 Start-Process "$S7zaExe" -ArgumentList "x -o`"c:\`" -y `"$destQt`"" -Wait -NoNewWindow
}

$script = "c:\\cygwin\\home\\vagrant\\script.sh"
$new_line = "`n"

[System.Console]::Writeline( "Generisem script za pokretanje HB build-a" )

$vagrant_dir = "/cygdrive/c/Users/vagrant"
$platform_dir = "/cygdrive/c/Platform"
$stream = [System.IO.StreamWriter] $script
$stream.Write("#!/bin/bash" + $new_line)

$stream.Write("tar xvfz $vagrant_dir/$file_java" + $new_line)
$stream.Write("rm $vagrant_dir/$file_java" + $new_line)

$stream.Write("mkdir hb" + $new_line)
$stream.Write("mkdir -p $platform_dir/HB" + $new_line)


$file_present = Test-Path "c:\Platform\PSQL\bin"
if (! $file_present) {

  $stream.Write("mkdir -p $platform_dir/PSQL" + $new_line)
  $stream.Write("cd $platform_dir/PSQL" + $new_line)
  $stream.Write("unzip -o $vagrant_dir/$file_psql" + $new_line)
  $stream.Write("rm $vagrant_dir/$file_psql" + $new_line)
}

$stream.Write('cd $HOME/hb' + $new_line)

$file_present = Test-Path "c:\cygwin\home\vagrant\hb\src"
if (! $file_present) {
  $stream.Write("tar xvfz /cygdrive/c/Users/vagrant/$file_hb" + $new_line)
  $stream.Write("rm /cygdrive/c/Users/vagrant/$file_hb" + $new_line)
}

$stream.Write("git checkout -f F18_master" + $new_line)
$stream.Write("export PATH=/opt/lo/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH" + $new_line)

$stream.Write('export C_ROOT=C:' + $new_line)
$stream.Write('export HB_ARCHITECTURE=win' + $new_line)
$stream.Write('export HB_COMPILER=mingw' + $new_line)
$stream.Write('export WIN_HOME=$C_ROOT\\Users\\vagrant' + $new_line)
$stream.Write('export QT_HOME=$C_ROOT\\Qt' + $new_line)
$stream.Write('export QT_VER=5.4' + $new_line)
$stream.Write('export MINGW_VER=491_32' + $new_line)
$stream.Write('export PSQL_HOME=$C_ROOT\\Platform\\PSQL' + $new_line)
$stream.Write('export TEMP=$C_ROOT\\tmp' + $new_line)
$stream.Write('export TMP=$C_ROOT\\tmp' + $new_line)
$stream.Write('mkdir -p /cygdrive/c/tmp' + $new_line)
$stream.Write('export HB_ROOT=$C_ROOT\\Platform\\HB' + $new_line)
$stream.Write('export QT_PLUGIN_PATH=$QT_HOME/$QT_VER/mingw$MINGW_VER/plugins' + $new_line)
$stream.Write('export PATH=$QT_HOME\\$QT_VER\\mingw$MINGW_VER\\bin:$HB_ROOT\\bin:$PSQL_HOME\\bin:$PATH' + $new_line)
$stream.Write('export PATH=$QT_HOME\\Tools\\mingw$MINGW_VER\\bin:$PATH' + $new_line)
$stream.Write('export HB_INC_INSTALL=$HB_ROOT\\include' + $new_line)
$stream.Write('export HB_LIB_INSTALL=$HB_ROOT\\lib' + $new_line)
$stream.Write('export HB_INSTALL_PREFIX=$HB_ROOT' + $new_line)
$stream.Write('export HB_WITH_QT=$QT_HOME\\$QT_VER\\mingw$MINGW_VER\\include' + $new_line)
$stream.Write('export HB_WITH_PGSQL=$PSQL_HOME\\include' + $new_line)
$stream.Write("./win-make.exe clean install" + $new_line)

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
