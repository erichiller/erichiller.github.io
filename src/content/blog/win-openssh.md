+++
title="Installing OpenSSH Server on Windows"
date=2015-12-06T12:00:00-08:00
tags=[
	"windows",
	"ssh"]
+++
Back in June of this year [Microsoft announced](https://blogs.msdn.com/b/powershell/archive/2015/06/03/looking-forward-microsoft-support-for-secure-shell-ssh.aspx) that they were working on a project to get `sshd` working proper on windows. Many, including myself didn't believe it at the time, but then it [surfaced again in October](https://blogs.msdn.com/b/powershell/archive/2015/10/19/openssh-for-windows-update.aspx), this time for real, and I paid attention. I took the time this evening to give it a go, and it does work, and you too can get it up and running in no time flat. Here's a quick how to:

# Server Side

First on the machine you intend to be your SSH Server:
1. Download from the [Win-OpenSSH package](https://github.com/PowerShell/Win32-OpenSSH/releases/download/11_09_2015/OpenSSH-Win32.zip)
2. Extract, and cd into the directory on the command line
3. In administrative powershell:

	./ssh-keygen.exe -t rsa -f ssh_host_rsa_key
	./sshd.exe install
	net start sshd

Down the road should you wish to uninstall:

	net stop sshd
	./sshd.exe uninstall

# Client

For the client it is simply

	./ssh.exe -l user@domain host
	
Then run the service you would like, such as `powershell`

# Additional Commands

You might have to open up the firewall:
	
	New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

And if you want to run the ssh server as a service, within powershell run:

	Set-Service sshd -StartupType Automatic

# References

For more information see the [docs on github](https://github.com/PowerShell/Win32-OpenSSH/wiki/Deploy-Win32-OpenSSH)