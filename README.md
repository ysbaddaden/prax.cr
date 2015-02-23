# Prax

Rack proxy server for development

This is an attempt to rewrite [Prax](https://github.com/ysbaddaden/prax) in
[Crystal](http://crystal-lang.org), a Ruby-inspired language that compiles
down to C. This should avoid problems with version managers, since Prax would
now be a binary application, yet remain as easily hackable as a Ruby
application, along with better performances (yay!).

This is in "working" state! Which means that it successfully proxies requests
to the Puma and Webrick Rack servers (others are untested).

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

Prax isn't ready for end-user consumption just yet, but if you want to
contribute, or feel adventurous, please follow the steps below.

Please note that only Linux is supported. On Mac OS X you'll may want to install
Pow!! (for the DNS resolver and the port redirection from :80 to :20559) and
then run Prax instead of Pow!!

1.
  Install the NSSWitch extension, then restart your browser:

    $ cd ext/
    $ make
    $ sudo make install

2.
  Install the iptables rules:

    $ sudo cp install/initd /etc/init.d/prax
    $ sudo update-rc.d prax defaults
    $ sudo /etc/init.d/prax start

3.
  Either install the Crystal 0.6.0 release, or clone and build the
  [master branch](https://github.com/manastech/crystal).

4.
  Compile Prax:

    $ make

  You'll may want to specify the crystal binary to use:

    $ make CRYSTAL_BIN=/path/to/crystal/bin/crystal

5.
  Prepare Prax environment:

    $ mkdir ~/.prax

6.
  Start Prax, and test that it works:

    $ ./bin/prax start
    $ firefox localhost

7.
  Link your applications, and enjoy:

    $ cd path/to/myapp
    $ prax link
    $ firefox myapp.dev

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

## Authors

- Julien Portalier <julien@portalier.com>
