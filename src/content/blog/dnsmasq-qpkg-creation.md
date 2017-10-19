+++
title="Creating dnsmasq QPKG"
date="2015-11-16"
tags=[
	"dnsmasq",
	"qpkg",
	"qnap",
	"dns"]
+++

In this article I am going to describe the steps I took to create the [dnsmasq](https://www.thekelleys.org.uk/dnsmasq/doc.html) [qpkg](https://www.qnap.com/i/useng/), which is an ongoing project I have, and is [listed on github as dnsmasq-qpkg](https://github.com/erichiller/dnsmasq-qpkg). I started this project back at the end of August 2015, because I wanted a [DNS server](https://en.wikipedia.org/wiki/Name_server) for my home that would allow me to:

1. Cache queries for increased speed / not call out the ISP
2. Avoid ad-queries, where the ISP returns Paid sites instead of NXDOMAIN (site not found)
3. (and most importantly) I have a lot of hosts as I am always testing something (mostly VMs and Raspberry PIs) I wanted to run shortnames so I didn't have to remember a thousand (not literally) IP addresses, ESPECIALLY when it came to IPv6.

I knew of dnsmasq from back in the glory days of running an ISP, not that I used it, as it was not multi-threaded, nor designed for large deployments, but it was lightweight and perfect for a household / SOHO (small business) environment. Many home router [linux / BSD distros](https://openwrt.org/) use it and it is known to be of high stability, fast, and feature rich. I looked at other software, but the choice was made relatively quickly.

After choosing dnsmasq, the choice of host was up next. As I mentioned, I had a number of Raspberry PIs, of cource a home router (Netgear R7000), and Virtual Machines. The Virtual Machines were all running on (at the time) a QNAP HS-251, which I later upgraded to a QNAP TS-453mini, both of which run [QEMU](https://wiki.qemu.org/Main_Page) underneath.  Turns out that support for 3rd party distros / OSes on the Netgear R7000 is lacking at best, I would be several revisions behind, not that it is a huge deal, but the other issue was, that in my experience, 3rd party distros, while amazing for wired and network services, leave a lot to be desired when it comes to wireless performance. I've never had great luck with htme in that respect. I tossed the idea of router as the dns host, even though that would have been by far the easiest solution, but hey, what can I say, I like to make life difficult (especially when it makes projects for me). 

Next up was the raspberry pi, and truth be told, I am breaking these things more than they are running. I am constantly writing stuff for them, or formatting them and reinstalling, which would be terrible for a DNS server, which is arguably the most important component of the network, or at least tied with the router and switches. And lastly was the Virtual Machine(s). I had the same issue as the Raspberry Pis, in that they are always go up and down. Sure I could have kept one persistent, but I don't trust the virtual MACs and the fast that QNAP has to boot the Virtual Machine AFTER it boots, thus it boots up far after QNAP and the rest of the network itself, leaving a large gap of dnslessness (hey I coined a term). I really wanted to run it on metal, and it wasn't going to be my windows desktop. I'd prefer to not buy anymore software when I had this perfectly beefly QNAP NAS sitting right there, doing next to nothing. QNAP it was!

Now the fun began. QNAP runs linux, sure, but it is an incredibly barebones linux. I mean baaaarrreeeeboneeesss. And to make less barebones is a pain in the rear. QNAP does provide the source for their QTS, but only for (at the time of this writing and the initial qpkg creation) 4.1.3. Well QTS 4.2.0 was freshly out, and I wanted to make use of some of its features. And I really didn't feel like getting into compiling my own kernel. This meant compiling a binary elsewhere and bringing it over. It had to have _as few dependencies as possible_ because QTS doesn't provide much in the way of libraries. Initially I was just going to compile it, scp it over and be done, bam 1 day of work. Well it ended up being weekends of work, so at that point I figured I'd at least let other people make use of the project, as during the course of doing research for it I found a number of other people with the same request. And if I was going to let it out into the wilds of the internet I may as well make it more valuable that a binary that had to be SCPed onto the box. So I set about making a nice QPKG, and web interface, and generally making it more usable and user friendly. 

I'm going to write up a series of articles about how I went about all of this, but I'm going to start off with the (relatively raw notes from my) process for creating the binary and qpkg. If this helps someone port to another processor / sytem architecture I would **GREATLY** appreciate your addition to my [github repo](https://github.com/erichiller/dnsmasq-qpkg) or if you have any other additions at all, I welcome contributors / contributions! Please let me know if you have any questions, suggestions or tips.

# dnsmasq Qpkg creation

# OS setup & libs

## Centos

Install the git pacakge

	yum install git
	
Install libidn from source

	wget https://ftp.gnu.org/gnu/libidn/libidn-1.32.tar.gz
	tar -zxvf libidn-1.32.Qtar.gz
	cd libidn-1.32
	./configure
	make
	make install

** Only used Centos for 64-bit build ** 

## Debian 

**(4r8 i386 is the closest; Run Old Debian Etch 4r8)**

Setup the apt sources to:

	deb https://snapshot.debian.org/archive/debian/20100101T152753Z/ etch main
	deb-src https://snapshot.debian.org/archive/debian/20100101T152753Z/ etch main

	deb https://snapshot.debian.org/archive/debian/20100101T152753Z/ etch contrib

### required libraries

`apt-get install build-essential git libidn11-dev`

**NOTE: static linking requires `libX.a` where X is the library abbreviation**

# dnsmasq

`git clone git://thekelleys.org.uk/dnsmasq.git`
or download the tar.gz file
`tar -zxvf dnsmasq-xxx-tar.gz`

in `src/config.h` 

Uncomment `#define HAVE_IDN` and add the line `#define HAVE_IDN_STATIC` (must have both).

Inotify won’t work unless you upgrade to 2.5 glibc minumum, which is experimental on etch, so I just turned inotify off; uncomment `#define NO_INOTIFY`

From the `dnsmasq` directory

`make`

# Notes

To compile dnsmasq with uclibc try using gmake by `make MAKE=gmake` and altering settings in src/config.h

# Some Useful Commands

**list groups**
`cut -d: -f1 /etc/group`

`scp root@testy:/root/dnsmasq/src/dnsmasq dnsmasq`

`scp src/dnsmasq admin@host:/tmp`

** see dependencies of library **
`ldd <binary>`

** see library version **
`readelf -V /path/to/library.so`

** opkg list and search for 'man' adding a new line between each entry **

	opkg list | grep man | awk '{print $0,"\n"}'

opkg installations

	opkg install git make

** SSH Keygen - create public & private key **

	ssh-keygen -N dnsmasq -t rsa -C "auto reboot dnsmasq webui" -f /share/CACHEDEV1_DATA/.qpkg/dnsmasq/id_rsa

** remove password from ssh key **

	openssl rsa -in id_rsa -out id_rsa_npw -passin pass:dnsmasq

reboot via localhost ssh login:

	ssh -i /share/CACHEDEV1_DATA/.qpkg/dnsmasq/id_rsa_npw -o StrictHostKeyChecking=no admin@localhost "/etc/init.d/dnsmasq.sh restart"

# Linux Information

## name service switch
NSS ( name service switch ) is provided by libc and is one of the primary reasons NOT to bundle libc statically, it will almost always break. Also, when you get a `user not found` error on another machine even though the user does _positively_ exist, its probably because the binary isn't linked properly to libc, which provides NSS, and access to `getpwnam`, etc...

NSS tells the libc function `getpwnam` where to look for users, groups

NSS was not working on my initial build because it was not properly linked to x86_64 libraries. I had to link dynamically via ldconfig

Check lib mapping / dependencies with ldd

# IPv6

** View IPv6 routes (linux) **
`ip -6 route`

Debian (and potentially other distros) may need another DHCP client besides the default ISC dhcpc, try:
`apt-get install dhcpcd5`

If you have a router or other devices on the network ensure router is set to **IP Address Assignment=Use DHCP Server**

Here is a [sample dnsmasq config](https://egustafson.github.io/ipv6-dhcpv6.html) as well as a dhcp client setup for linux.

[Juniper has an excellent sample Router Advertisement article](https://www.juniper.net/techpubs/en_US/junos13.3/topics/topic-map/ipv6-interfaces-neighbor-discovery.html)

For the various IPv6 dhcp modes, see the [dnsmasq manpage - scroll down to 'dhcp-range'](https://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html)

# Notes on QTS structure

## Kernel version

via `uname -r`:

Distro			| Kernel
---				|---	
CentOS 7		| 3.10.0-229.el7.x86_64
QNAP 4.2.0 rc5	| 3.12.6

PHP binary / exe location on QNAP is `/mnt/ext/opt/apache/bin/php`

The way I had 64-bit libs working before was to:  
add `/share/CACHEDEV1_DATA/.qpkg/HD_Station/lib/x86_64-linux-gnu/`  
to `/etc/ld.so.conf`  
then run `ldconfig` to refresh the cache  
** this has to be done in the dnsmasq init script as `/etc/ld.so.conf` is reset upon reboot.

view the current libraries and their dependencies and locations via `ldconfig -p`

**ENSURE IPV6 IS ENABLED on nas**  
can check for IPV6 in `/etc/config/uLinux.conf`  
under Network section IPV6 = TRUE / FALSE  

## Notes on QDK & QPKG

located in `/share/CACHEDEV1_DATA/.qpkg/QDK/`

qdk is the init script to the qbuild application in /usr/bin.

`qbuild` is the build script

qinstall.sh is the install script

QNAP qpkg descriptions are in `/etc/config/rssdoc/qpkgcenter.xml` but that file is updated every so often, so even if I dropped some info in there it would get erased the next time the cache was updated

### READ ONLY variables in QDK qbuild

* SYS_CONFIG_DIR -> `/etc/config`

* SYS_INIT_DIR -> `/etc/init.d`

* SYS_RSS_IMG_DIR -> `/home/httpd/RSS/images`

* SYS_QPKG_DIR -> Location of installed software

icons go to: `/home/httpd/RSS/images/`

### QPKG config

Installed QPKG and its config data is registered in `/etc/config/qpkg.conf`

### getcfg
Command takes the form of

	getcfg <section> <field>

`-u` flag converts to uppercase

`-d "DEFAULTTEXT"` flag returns DEFAULTTEXT if field is not found

getcfg is looking for a file of structure (such as `/etc/config/qpkg.conf` )

	[section]
	field=value
	field="val ue third"
	field = value
	
# Conclusion and more to come...

I hope that this at least outlined the QTS structure and process to make dnsmasq build that is compatible with QTS. There may be some gaps, and if you find any please do let me know, and I will fill them in. I plan to regularly update the GUI and add addtional features in the future, and work love to add ARM builds of dnsmasq. I'd love to hear how you all are using dnsmasq in your networks as well, especially if it is in larger deployments.

-Eric
