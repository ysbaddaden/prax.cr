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

1. resolves `*.test` domains to 127.0.0.1 / ::1 (localhost)
2. redirects the :80 and :443 ports to :20559 and :20558
3. receives incoming HTTP requests and extracts the hostname (eg: myapp.test)
4. spawns a Rack applications (found at `~/.prax/myapp`) if any
5. proxies the request to the spawned Rack aplication or to the specified port.

### `.test` TLD

Prax proposes 2 solutions to resolve `.test` domains:

- a dnsmasq configuration, either throught NetworkManager or by installing
  dnsmasq manually (eg. through your Linux distribution package);
- an obsolete and deprecated NSSwitch extension, only compatible wih glibc
  and no longer compatible with Google Chrome/Chromium, and certainly more;

Prax also supports http://xip.io domains, so you may use
`myapp.129.168.0.1.xip.io` for example. This is very useful when using an
external device like a smartphone or tablet or another computer.

If your computer runs systemd, it's possible a service such as
`systemd-networkd` or `systemd-resolved` or something else systemd took over,
is conflicting with a local resolver. I don't have a solution —except to stay
as far away as possible from systemd as possible.


### Port Redirections

The port redirections are iptables rules, that are installed and removed using
an initd script. The script redirects the port :80 and :443 on 127.0.0.1 and for
each `wlanX` and `ethX` devices found on your machine, to allow incoming
traffic, so you may use xip.io to test on external devices, as mentioned above.


### Issues

In Chrome, if one types "myapp.test" into the URL bar, Chrome will issue a
search.  Type "http://myapp.test" or "myapp.test/" instead to visit that URL.


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
