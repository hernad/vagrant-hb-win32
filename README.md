# setup w7-choco-bs vagrant box

     curl -LO ftp://ftpadmin:mypassword@router-7.bring.out.ba/Main/files/Platform/vagrant-w7-choco-bs.box
     vagrant box add w7-choco-bs vagrant-w7-choco-bs.box

## build harbour

   ./vagrant_harbour.sh

## build F18

  ./vagrant_F18.sh



## Settings


ftp_password.config:

<files_bring.out.ba_admin_password>



hernad_ssh.key 

-----BEGIN RSA PRIVATE KEY-----
MII ....

