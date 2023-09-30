# Docker Prowlarr

Provide a simple docker image for [`prowlarr`].

[`prowlarr`]: https://github.com/Prowlarr/Prowlarr

The goal is to provide a simpler docker image that don't package a bootstrap script like [`linuxserver/prowlarr`] to be used on `docker-compose` & `k8s`.

[`linuxserver/prowlarr`]: https://github.com/linuxserver/docker-prowlarr

The image is provided at <https://hub.docker.com/r/firelightflagbot/prowlarr>

## Quick start

Here is a simple `docker-compose` file:

```yaml
services:
  prowlarr:
    image: firelightflagbot/prowlarr:latest
    user: 1234:1234 # This is the default uid/gid, you can change it.
    ports:
      - 9696:9696
    volumes:
      - type: bind
        source: /somewhere/prowlarr-config # The folder need to be owned by the set'd user in `services.prowlarr.user` (prowlarr need to be able to write to it).
        target: /config
```
