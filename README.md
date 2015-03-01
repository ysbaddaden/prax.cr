# Prax

Rack proxy server for development

This is an (almost) complete rewrite of [Prax](https://github.com/ysbaddaden/prax)
in [Crystal](http://crystal-lang.org), a Ruby-inspired language that compiles
down to LLVM. This version should avoid problems with version managers, since Prax
is now a binary application that don't rely on Ruby anymore (except for Rack and
`rackup`).

Please refer to the wiki for more information:

- [Manual Install Guide](https://github.com/ysbaddaden/prax.cr/wiki/Manual-Install-Guide)
- [User Guide](https://github.com/ysbaddaden/prax.cr/wiki/User-Guide)


## How it works

1. resolves `*.dev` domains to 127.0.0.1 (localhost)
2. redirects the :80 and :443 ports to :20559 and :20558
3. receives incoming HTTP requests and extracts the hostname (eg: myapp.dev)
4. spawns a Rack applications (found at `~/.prax/myapp`) if any
5. proxies the request to the spawned Rack aplication or to the specified port.

### `.dev` TLD

The `.dev` domain resolver is a NSSwitch extension. You'll may prefer to
configure dnsmasq or another local DNS server to resolve `.dev` domains to
127.0.0.1 or ::1 instead.

This step is crucial: your DNS servers must either always resolve `.dev` domains
to 127.0.0.1 or never resolve them —so the NSSwitch extension will do it. Please
troubleshoot with `getent hosts myapp.dev` (it must return 127.0.0.1) and `host
myapp.dev` (should fail).

Prax also supports http://xip.io domains, so you may use
`myapp.129.168.0.1.xip.io` for example. This is very useful when using an
external device like a smartphone or tablet or another computer.

### Port Redirections

The port redirections are iptables rules, that are installed and removed using
an initd script. The script redirects the port :80 and :443 on 127.0.0.1 and for
each `wlanX` and `ethX` devices found on your machine, to allow incoming
traffic, so you may use xip.io to test on external devices, as mentioned above.


## Install

Prax is getting ready for end-user consumption, but is still missing an easy
setup. You'll may want to follow the
[Manual Install Guide](https://github.com/ysbaddaden/prax.cr/wiki/Manual-Install-Guide)
until deb and rpm packages are built and tested.


## TODO

Lot of work is still required: evented or thread pool of incoming requests,
keepalive connections, proxying websockets, SSL server, etc.

- [x] restart rack application (`tmp/restart.txt`, `tmp/always_restart.txt`)
- [x] logger (to debug prax activity)
- [x] read .env files before spawning apps
- [x] handle connections in threads
- [x] keepalive connections
- [x] proxy transfer-encoding:chuncked
- [ ] proxy websockets
- [x] directly serve files in public folder
- [ ] SSL server
- [ ] DEB / RPM packages
- [x] daemonize prax binary (with command line switch)


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
