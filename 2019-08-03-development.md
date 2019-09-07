---
layout: post
title: Vulnhub - Development writeup
date: 2019-08-03 10:56
---
<h1 align="center" style="font-size:30px;">
  <br>
  <a href="https://www.vulnhub.com/entry/digitalworldlocal-development,280/">digitalworldlocal-Development</a>
  <br>
</h1>

<h4 align="center"> Author: <a href="https://donavan.sg/blog"> Donavan</a></h4>

## Nmap

![](images/dev/nmap.png)

![](images/dev/nmap-2.png)

![](images/dev/nmap-3.png)

There's lot of information in nmap output. But let's start with SMB.

***

## SMB

![](images/dev/shares.png)

There is a share named `access` but we can't login into it without any credentials. This mean we shouldn't have started with SMB 😜😜

***

## HTTP

![](images/dev/website.png)

It says that we can get a list of pages on `html_pages`. So I visited `http://192.168.184.130:8080/html_pages`

![](images/dev/html.png)

This looks like the output of the `ls -la` command or something similar.

On the `/development.html` I found a comment to a so called secret page.

![](images/dev/development.png)

On visiting `developmentsecretpage/` we get another link to `/patrick.php`

![](images/dev/secretpage.png)

Following the trail I visited `/developmentsecretpage/patrick.php`

![](images/dev/patrick.png)

If we open the `/sitemap` page we again see some stuff.

![](images/dev/sitemap.png)

The `/securitynotice` page contained some information about the passwords.

![](images/dev/notice.png)

Since I had an idea of what password might be in play I clicked on the `logout` option and then tried to login as `patrick` and `admin` but none of them work. Instead I kept getting error.

![](images/dev/error.png)

I googled that and found [exploit-lfi-bug-when-a-inc-php-is-appended-to-the-file-name](https://security.stackexchange.com/questions/181704/exploit-lfi-bug-when-a-inc-php-is-appended-to-the-file-name)
After this I decided to look for an exploit on exploit-db and found [Simple Text-File Login script (SiTeFiLo) 1.0.6 - File Disclosure / Remote File Inclusion](https://www.exploit-db.com/exploits/7444). In there was a section called `[0x03] Bug:[Sensitive Data Disclosure]` which showed a path called `slog_user.txt`

![](images/dev/slog.png)

If we try to open `developmentsecretpage/slog_users.txt` we get the credentials.

![](images/dev/credentials.png)

```
admin, 3cb1d13bb83ffff2defe8d1443d3a0eb
intern, 4a8a2b374f463b7aedbb44a066363b81
patrick, 87e6d56ce79af90dbe07d387d3d0579e
qiu, ee64497098d0926d198f54f6d5431f98
```

Since all the passwords are in `md5` hash I used [crackstation](https://crackstation.net/) to crack them and was able to get the password for `intern` and `qiu`.

![](images/dev/crack.png)

`intern: 12345678900987654321`
`qiu: qiu`
`patrick: P@ssw0rd25`

The `qiu` login didn't work on SSH but intern one worked.

![](images/dev/ssh.png)

***

## User shell

We were logged in via SSH but the problem is that it was a `restricted shell` meaning it had only few commands.

![](images/dev/rshell.png)

I tried running commands like `/bin/sh` or `/bin/bash` but I got kicked out 😡😡.

![](images/dev/kick.png)

Then it clicked that if we can run command like `echo` meaning we can open shell using `os.system()`

I ran `echo os.system("/bin/sh")` and it gave me a proper shell and then I got a `congrats` in `local.txt` file.

![](images/dev/user.png)

***

## Privilege escalation

Since we have the user shell now we can try to change user to `patrick` since he's the head of the department and might have more power.

I tried `su patrick` with password as `P@ssw0rd25` and it worked.

![](images/dev/su.png)

Then the first thing I checked was `sudo rights` and patrick could run `vim/nano` as root 😏😏.

![](images/dev/sudo.png)

I immediately searched gtfobin for `vim` and found [vim/sudo](https://gtfobins.github.io/gtfobins/vim/#sudo)

So I ran `sudo vim -c ':!/bin/sh'` to get a root shell.

![](images/dev/root-shell.png)

![](images/dev/root.png)

***

## Extra

There are other ways to root this machine.

### Kernel exploit

I found a [kernel exploit](https://github.com/bcoles/kernel-exploits/tree/master/CVE-2018-18955). I downloaded all the files, compiled them and actually good a shell as `nobody` but I was able to `cd` to `/root` and get the flag.

![](images/dev/cve.png)

To be honest I am not sure how it works but it does ;-)

### With lxd container

I checked the `/etc/group` file to found out that there's a group named `lxd` with `patrick` in it.

I found a exploit related to `lxd` on exploit db i.e [Ubuntu 18.04 - 'lxd' Privilege Escalation](https://www.exploit-db.com/exploits/46978).

![](images/dev/lxd.png)

Follow the steps in the exploit to get the `alpine-v3.10-x86_64-20190730_0048.tar.gz` file.

***

This is a really nice machine with a beginner-intermediate difficulty. I really enjoyed it, especially finding other method to root it.

Thanks to [Donavan](https://donavan.sg/blog) for this machine.

***

Thanks for reading, Feedback is always appreciated.

Follow me [@0xmzfr](https://twitter.com/0xmzfr) for more “Writeups”.
