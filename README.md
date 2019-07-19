# Server Side

A C framework for server implementations

![Platform][platform-badge]
[![License][mit-badge]][mit-url]
[![Build Status](https://travis-ci.org/nineteen-apps/ServerSide.svg?branch=master)](https://travis-ci.org/nineteen-apps/ServerSide)

# Project Goals

Server Side is a small project which aim is to create all boiler plate code for
a unix server, integrating:

- [ ] startup systems support, like System V or upstart;
- [ ] configuration files in several formats like INI, Yaml, XML, etc;
- [ ] system logging with Syslog
- [ ] signal handling
- [ ] IPC support
- [ ] process priority control

Server software is basicaly a repetition of those features. So, Server Side is
intended to create the full run-time so you have to worry about writing what
matters: your business code.

# Current State

This project was originally written in Swift language. It is being ported to C
due its small footprint.

## License

This software is distributed under [MIT License][mit-url].

[platform-badge]: https://img.shields.io/badge/Platform-unix%20and%20linux-brightgreen.svg
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
