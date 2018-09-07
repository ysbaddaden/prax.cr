# CHANGELOG

## v0.8.0 - 2018-09-07

Enhancements:
- Allow to port forward to specific host with `host:port` host file (and
  `[ipv6]:port` for IPv6 addresses.

Breaking changes:
- default to `.test` TLD by default instead of Google-owned `.dev` domain that
  requires HTTPS to be configured.

Fixes:
- HTTP headers lookups are case-insensitive.
- Crystal 0.24+ compatibility.
- Debian 9 packaging issues.

## v0.7.0

Enhancements:
- Added `--ssl-port` configuration option.
- Added `--timeout` (`PRAX_TIMEOUT`) configuration option to wait longer or
  shorter than 60 seconds for applications to start.
- Detect real hardware devices to apply port redirection on (supports weird
  systemd predictable interface names).
- Compatibility with the dotenv gem.

Breaking changes:
- Setting environment variables via `.env` files has been removed. Use the
  `.praxrc` shell file in your project to set environment variables instead.

## v0.6.1

Fixes:
- Only redirect traffic from wlan/eth devices.

## v0.6.0

Enhancements:
- Source `.praxrc` shell files in projects (eg: to configure variables, version
  managers, ...)
- Move iptables rules to `prax iptables` command
- Upgraded to Crystal 0.18+

Fixes:
- Multiple Forwarding of repeated headers (cookies were broken)
- Unescape filenames before searching in the public folder

## v0.5.1

Fixes:
- Upgraded to Crystal 0.11.0 (syntax changes)
- Correct values for X-Forwarded-Proto proxy header (https, http)
- Leaks file descriptors, see https://github.com/manastech/crystal/issues/1700

## v0.5.0

Enhancements:
- Upgraded to Crystal 0.8.0 (uses standard Process.new, dropped deprecations)
- Generic SIGCHLD handler to reap zombie children (no more reap threads)

Fixes:
- Proxy middleware was always run after public file middleware

## v0.4.2

Features:
- Prax now logs on `~/.prax/_logs.prax.log` when daemonized

Fixes:
- Prax crashed when starting as a daemon
- Prax hanged forever with concurrent requests to an app while it spawned

## v0.4.1

- Better Debian packages
- Compatibility with Crystal v0.7.3

## v0.4.0

- Compatibility with Crystal v0.7.x
- Handle requests in an event loop, see #3

## v0.3.0

- Start an HTTPS server along the HTTP server, see #5
- Sets proxy headers (X-Forwarded-For, ...), see #6
- Handle requests with a pool of threads (avoids a memory leak, see #8)
- Resolve dev domains using dnsmasq instead of NSSwitch, see #9

## v0.2.0

Initial release.
