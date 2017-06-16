# Server Side

A swift implementation for a server application.

[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Build Status](https://travis-ci.org/nineteen-apps/ServerSide.svg?branch=master)](https://travis-ci.org/nineteen-apps/ServerSide)

# Project Goals

Server Side is a small project which aim is to create all boiler plate code for
a unix server, integrating:

- [x] startup systems support, like System V or upstart;
- [ ] configuration files in several formats like INI, Yaml, XML, etc;
- [x] system logging with Syslog
- [x] signal handling
- [ ] IPC support
- [ ] process priority control

Server software is basicaly a repetition of those features. So, Server Side is
intended to create the full run-time so you have to worry about writing what
matters: your business code.

# Requirements

This project is written using Swift 3. As soon as Swift 4 gets available for
production, the full project will be migrated.

## Zewo

Zewo is a dependency for ServerSide. ServerSide starts your code inside a
co-routine and manages all of it using Venice primitives. Therefore, ServerSide
is the natural entry point for Zewo-enabled servers.

## License

This software is distributed under [MIT License][mit-url].

[platform-badge]: https://img.shields.io/badge/Platform-Mac%20%26%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
