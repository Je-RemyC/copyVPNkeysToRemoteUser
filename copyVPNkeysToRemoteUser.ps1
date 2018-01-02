#########################################################################################
#
#   Open VPN - push CA keys and a configured OVPN file to a remote workstation
#  25/05/17
#
##########################################################################################
 

[CmdletBinding()]
Param (
  [Parameter(Mandatory=$True,Position=0)]
  [string]$RemoteMachine,
  
  [Parameter(Mandatory=$True,Position=1)]
  [string]$RemoteUser,

  [Parameter(Mandatory=$True,Position=2)]
  [string]$SuperAdminUsername,

  [Parameter(Mandatory=$True,Position=3)]
  [string]$SuperAdminPasswd,
  
  [Parameter(Mandatory=$True,Position=4)]
  [string]$CA_connect
)

 # Script runs Test-Connection against the remote machine 

 
 if (Test-Connection -computername $RemoteMachine -Quiet -Count 1) 
 {

 write-host = "Continue"
   
 } 


 # Script stops if Test-Connection fails 

 
 else {

     Write-Host = "Can't find the remote machine. Script will exit"
 
     Exit
 }


 # Check for the presence of the _ssh folder and create it if it doesn't exist


$SSHFolder="\\$RemoteMachine\c$\Users\$RemoteUser\_ssh"

 if( -Not (Test-Path -Path $SSHFolder ) )
{
    New-Item -ItemType directory -Path $SSHFolder
}


 # Perform actions against CA


  plink -ssh -v $CA_connect "sudo mount -t cifs //$RemoteMachine/c$/users/$RemoteUser/_ssh /mnt -o username=$SuperAdminUsername,password=$SuperAdminPasswd"

  plink -ssh -v $CA_connect "sudo cp /easy-rsa/2.0/keys/$RemoteUser.csr /mnt"
  plink -ssh -v $CA_connect "sudo cp /easy-rsa/2.0/keys/$RemoteUser.crt /mnt"
  plink -ssh -v $CA_connect "sudo cp /easy-rsa/2.0/keys/$RemoteUser.key /mnt"
 
  plink -ssh -v $CA_connect "sudo cp /easy-rsa/2.0/keys/ca.crt /mnt"
  
 
 
 # Check for the presence of the OpenVPN Config folder location on the remote workstation. If the folder doesn't exist, it is created

 
 $VpnConfig="Y:\Infrastructure\Internal IT\Office\VPN\OpenVPN\sample-config.ovpn"
 $VpnConfigDestination="\\$RemoteMachine\C$\Program Files\OpenVPN\config"


 if( -Not (Test-Path -Path $VpnConfigDestination ) )
{
    New-Item -ItemType directory -Path $VpnConfigDestination
}

 
 # Fetch the Open VPN config file fron the Y: drive and copy it to the remote users workstation, replacing <blah> with their username, 
 # and .ssh with _ssh

 
 (Get-Content $VpnConfig) | Foreach-Object {
     $_ -replace '<blah>', "$RemoteUser" `
        -replace '.ssh', '_ssh' `
       } | Set-Content "$VpnConfigDestination\$RemoteUser-config.ovpn"


 # Umount the Windows directory share on CA


 plink -ssh -v $CA_connect "sudo umount /mnt"








