# Prax

Rack proxy server for development

This is an (almost) complete rewrite of [Prax](https://github.com/ysbaddaden/prax)
in [Crystal](http://crystal-lang.org), a Ruby-inspired language that compiles
down to LLVM. This version should avoid problems with version managers, since Prax
is now a binary application that don't rely on Ruby anymore (except for Rack and
`rackup`).

Please refer to the wiki for more information:

- [User Guide](https://github.com/ysbaddaden/prax.cr/wiki/User-Guide)


## Install

You can download a Debian / Ubuntu package for 64bits kernel on the
[releases page](https://github.com/ysbaddaden/prax.cr/releases).
For other systems, you'll have to follow the
[Manual Install Guide](https://github.com/ysbaddaden/prax.cr/wiki/Manual-Install-Guide).


## How it works

1. resolves `*.test` and `*.localhost` domains to `127.0.0.1` and `::1` (localhost);
2. redirects the :80 and :443 ports to :20559 and :20558;
3. receives incoming HTTP requests and extracts the hostname (eg: `myapp.test`);
4. serves static files directly if they exist;
4. otherwise spawns a Rack applications (found at `~/.prax/myapp`) if any;
5. and proxies the request to the Rack aplication or a specified port for port forwarding.

## Domain Resolver

### systemd

If your distribution uses `systemd-resolved`, just use the `.localhost` TLD
instead of `.test` —be prepared to fight against systemd if you want to use
another TLD, or consider switching to a systemd free Linux.

### `.test` TLD

Prax proposes 2 solutions to resolve `.test` and `.localhost` domains:

- a dnsmasq configuration, either throught NetworkManager or by installing
  dnsmasq manually (eg. through your Linux distribution package);
- an obsolete and deprecated NSSwitch extension, only compatible wih glibc
  and no longer compatible with Google Chrome/Chromium, and certainly more.

### nip.io

Prax supports http://nip.io/ domains, so you can use `myapp.129.168.0.1.nip.io`
for example. This is useful when using an external device like a smartphone,
tablet or another computer to test your websites on.

### Custom TLD

If `.test` or `.localhost` domains are not your cup of tea, no problem! Prax
will route requests from any TLD to the applications in your `~/.prax`
directory, as long as the domain resolves to localhost.

For instance, if you wished to visit `myapp.dev` instead of `myapp.test`, you
could create dnsmasq configuration to resolve `.dev` domains to localhost, too:

```
$ sudo tee /etc/dnsmasq.d/dev <<EOF
local=/dev/
address=/dev/127.0.0.1
address=/dev/::1
EOF
$ sudo service dnsmasq restart
```


## Port Redirections

The port redirections are iptables rules, that are installed and removed using
an initd script. The script redirects the port :80 and :443 on 127.0.0.1 and for
each `wlanX` and `ethX` devices found on your machine, to allow incoming
traffic, so you can use http://nip.io to test on external devices, as mentioned
above.

You can install or remove the redirections with:

```console
$ prax iptables [start|stop|restart|status]
```

Distribution packages should configure an init service to always install the
iptables rules on machine startup or before starting prax (warning: this
requires root privileges).


## License

Prax is distributed under the [CeCILL 2.1 license](http://www.cecill.info).
Please see LICENSE for details.

HTML templates for rendering errors are from [Pow!!](http://pow.cx/), by Sam
Stephenson and Basecamp, and are under the [MIT license](http://www.opensource.org/licenses/MIT).

The NSSwitch extension originaly come from [Hoof](https://github.com/pyromaniac/hoof),
by pyromaniac, and is under the [MIT license](http://www.opensource.org/licenses/MIT).


## Credits

- Julien Portalier <julien@portalier.com>

Prax wouldn't exist without [Pow!!](http://pow.cx) by Sam Stephenson and
Basecamp. Prax is nothing more but a reimplementation (in another language)
with Linux compatibility in mind.
