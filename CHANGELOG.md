# CHANGELOG

## Unreleased

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
