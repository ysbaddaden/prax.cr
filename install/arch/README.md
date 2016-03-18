# A way to run Prax on Arch Linux

We need to do a few things:

1. make traffic to \*.dev go to localhost (with dnsmasq)
2. forward traffic on port 80/443 to 22559/22558 (with iptables)
3. start the prax daemon itself when you log in


## 1. Forwarding \*.dev to localhost

You can do this by putting the prax domain resolver in `/etc/nsswitch.conf`. This won't work with any recent version of Chrome (or Chromium) though as it completely bypasses your name service configuration. (See [prax issue #117](https://github.com/ysbaddaden/prax/issues/117) for more info.)

Luckily Dnsmasq provides a solution. Dnsmasq acts like a local caching DNS server. It can do a lot more though; you should check it out.

```shell
sudo pacman -S dnsmasq
# and make sure it is running
```

To configure Dnsmasq to forward \*.dev you can use the file [dnsmasq](./dnsmasq) that is also present in this directory. Copy it to the right location: `/etc/NetworkManager/dnsmasq.d/prax` and restart NetworkManager.

```shell
sudo systemctl restart NetworkManager.service
```

## 2. Set up iptables

Look at these files: [prax-iptables](./prax-iptables) and [prax-iptables.service](./prax-iptables.service).

The first file is an slightly changed version of the init script you can find in the install/debian-directory. This version doesn't use ifconfig to find the network devices. Copy this file to `/usr/local/sbin/prax-iptables`.

The second file is the systemd-service that is meant to run `/usr/local/sbin/prax-iptables` on startup. Copy this file to `/etc/systemd/system/prax-iptables.service`.

You should also enable and start the service with `systemctl`.

## 3. Start Prax when you log in

*Option 1:* Let your desktop manager start Prax. Copy [prax.desktop](../prax.desktop) to `~/.config/autostart/`. Gnome will automatically run it when you log in. This is the way ysbaddaden runs it. I don't know what it does when you log in twice (with mutliple X-servers). However this should probably not be a real problem I guess.

*Option 2:* Let the per-user systemd instance handle it. Copy [prax.service](../prax.service) to `~/.config/systemd/user/prax.service` and change the lines that say `ExecStart` and `ExecStop` to reflect the correct path where you installed Prax. Note that this is a per-user process, and not per-session.

Note that you should also enable and start this service with `systemctl --user`.
