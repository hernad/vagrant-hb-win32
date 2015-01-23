function Download-File {
 param (
  [string]$url,
  [string]$file,
  [bool]$is_ftp = $false
 )

[System.Console]::Writeline( "---- download url: $url, FTP: $is_ftp ------ " )

$file_exists = (Test-Path $file)

if ( $file_exists ) {
   [System.Console]::Writeline( "File already exists - no download: $file" )
   return $false
}


switch ($is_ftp)
{
    $true { 

      $ftp_pwd_file = "c:\vagrant\ftp_password.config"
      if (! (Test-Path $ftp_pwd_file) ) {
        [System.Console]::WriteLine( "U vagrant direktoriju se ne nalazi $ftp_pwd_file !" )
         exit 1
      }
      $user = "ftpadmin"
      [System.Console]::WriteLine("U vagrant direktoriju se nalazi ftp_password.config")
      $pass = Get-Content( $ftp_pwd_file )
      [System.Console]::WriteLine( "ftp pasword je: $pass" )

      $webclient = New-Object System.Net.WebClient
      $webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)
      break 
    }

    default { 
      $webclient = New-Object System.Net.WebClient
      $webclient.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;
      break 
   }

}

 [System.Console]::Writeline( "Downloading $url to $file" )
 $webclient.DownloadFile($url, $file)

 return $true

}

# http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/

$bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
$objectRef = $host.GetType().GetField("externalHostRef", $bindingFlags).GetValue($host)
$bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetProperty"
$consoleHost = $objectRef.GetType().GetProperty("Value", $bindingFlags).GetValue($objectRef, @())
[void] $consoleHost.GetType().GetProperty("IsStandardOutputRedirected", $bindingFlags).GetValue($consoleHost, @())
$bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
$field = $consoleHost.GetType().GetField("standardOutputWriter", $bindingFlags)
$field.SetValue($consoleHost, [Console]::Out)
$field2 = $consoleHost.GetType().GetField("standardErrorWriter", $bindingFlags)
$field2.SetValue($consoleHost, [Console]::Out)


$ssh_key_file = 'c:\vagrant\hernad_ssh.key'
if (! (Test-Path $ssh_key_file) ) {
   [System.Console]::WriteLine( "U vagrant direktoriju se ne nalazi $ssh_key_file !" )
   exit 1
}


$installDir = 'c:\Users\vagrant'
$ftp = "ftp://router-7.bring.out.ba/Main/files/Platform/"
$ftp_win32 = "ftp://router-7.bring.out.ba/Main/files/Platform/win32/"

$file = "cygwin-3.7z"
$file_qt = "Qt_54_mingw_win32.7z"
$file_hb = "HB_Platform_win32.zip"
$file_java = "home_java.tar.gz"
$file_psql = "PSQL_Platform.zip"
$file_f18 = "F18_git.tar.gz"

$destCygwin = Join-Path $installDir $file
$destQt = Join-Path $installDir $file_qt
$destJava = Join-Path $installDir $file_java
$destHb = Join-Path $installDir $file_hb
$destPSQL = Join-Path $installDir $file_psql
$destF18 = Join-Path $installDir $file_f18

$url = $ftp + $file
Download-File $url $destCygwin $true

$url_qt = $ftp + $file_qt
Download-File $url_qt $destQt $true

$uri_hb = $ftp + $file_hb
Download-File $uri_hb $destHb $true

$uri_java = $ftp + $file_java
Download-File $uri_java $destJava $true

$uri_psql = $ftp_win32 + $file_psql
Download-File $uri_psql $destPSQL $true

$uri_psql = $ftp + $file_hb
Download-File $uri_psql $destHb $true

$uri_f18 = $ftp + $file_f18
Download-File $uri_f18 $destF18 $true


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
# $stream.Write("rm $vagrant_dir/$file_java" + $new_line)

$stream.Write("mkdir F18_knowhow" + $new_line)
$stream.Write("mkdir -p $platform_dir/HB" + $new_line)


$file_present = Test-Path "c:\Platform\PSQL\bin"
if (! $file_present) {

  $stream.Write("mkdir -p $platform_dir/PSQL" + $new_line)
  $stream.Write("cd $platform_dir/PSQL" + $new_line)
  $stream.Write("unzip -o $vagrant_dir/$file_psql" + $new_line)
}

$file_present = Test-Path "c:\Platform\HB\bin"
if (! $file_present) {

  $stream.Write("mkdir -p $platform_dir/HB" + $new_line)
  $stream.Write("cd $platform_dir/HB" + $new_line)
  $stream.Write("unzip -o $vagrant_dir/$file_hb" + $new_line)
}

$stream.Write('cd $HOME/F18_knowhow' + $new_line)

$file_present = Test-Path "c:\cygwin\home\vagrant\F18_knowhow\F18.hbp"
if (! $file_present) {
  $stream.Write("tar xvfz /cygdrive/c/Users/vagrant/$file_f18" + $new_line)
  # $stream.Write("rm /cygdrive/c/Users/vagrant/$file_f18" + $new_line)
}

$stream.Write("git checkout -f 1.7" + $new_line)
$stream.Write("git clean -d -fx" + $new_line)
$stream.Write("git pull" + $new_line)
$stream.Write("export PATH=/opt/lo/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH" + $new_line)

$stream.Write('export C_ROOT=C:' + $new_line)
$stream.Write('export HB_PLATFORM=win' + $new_line)
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

$stream.Write('echo `pwd`' + $new_line)
$stream.Write('./build_release.sh' + $new_line)
$stream.Write('cp /cygdrive/c/vagrant/hernad_ssh.key $HOME' + $new_line)
$stream.Write('chown vagrant $HOME/hernad_ssh.key' + $new_line)
$stream.Write('chmod 0700 $HOME/hernad_ssh.key' + $new_line)
$stream.Write("scripts/build_gz.sh XX --push" + $new_line)

$stream.close()

$command = @'
$env:Path = "c:\\cygwin\\bin;" + $env:Path
chdir c:\\cygwin\\home\\vagrant
bash script.sh
'@

Invoke-Expression -Command:$command
