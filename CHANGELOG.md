# CHANGELOG

## v0.6.1

Fixes:
- Only redirect traffic from wlan/eth devices.

## v0.6.0

Enhancements:
- Source `.praxrc` shell files in projects (eg: to configure variables, version managers, ...)
- Move iptables rules to `prax iptables` command
- Upgraded to Crystal 0.18+

Fixes:
- Multiple Forwarding of repeated headers (cookies were broken)
- Unescape filenames before searching in the public folder

## v0.5.1

Enhancements:

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
