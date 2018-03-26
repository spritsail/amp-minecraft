[hub]: https://hub.docker.com/r/spritsail/amp-minecraft
[git]: https://github.com/spritsail/amp-minecraft
[drone]: https://drone.spritsail.io/spritsail/amp-minecraft
[mbdg]: https://microbadger.com/images/spritsail/amp-minecraft

# [Spritsail/AMP-Minecraft][hub]
[![Layers](https://images.microbadger.com/badges/image/spritsail/amp-minecraft.svg)][mbdg]
[![Latest Version](https://images.microbadger.com/badges/version/spritsail/amp-minecraft.svg)][hub]
[![Git Commit](https://images.microbadger.com/badges/commit/spritsail/amp-minecraft.svg)][git]
[![Docker Stars](https://img.shields.io/docker/stars/spritsail/amp-minecraft.svg)][hub]
[![Docker Pulls](https://img.shields.io/docker/pulls/spritsail/amp-minecraft.svg)][hub]
[![Build Status](https://drone.spritsail.io/api/badges/spritsail/amp-minecraft/status.svg)][drone]

A Docker image for running the Minecraft module of the [AMP][git] server management program, by CubeCoders.

## Environment Variables
This Dockerfile requires a CubeCoders licence, specified as the environment variable LICENCE. An example run command for this Dockerfile is:

```bash
docker run -d -e "LICENCE=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" -p 8080:8080  -p 25565:25565 -v /host/path/to/amp:/ampdata spritsail/amp-minecraft
```

To rebind the port the Minecraft server listens on, simply replace the first intance of 25565 with the external port.

This dockerfile also support more environment variables to customise the minecraft servere parameters. These are:
* **HOST** - Specifies the interface AMP and the minecraft server should listen on
* **PORT** - The port for the AMP webUI
* **USERNAME** - The default username for logging into the webUI
* **PASSWORD** - The default password for logging into the webUI
* **INSTANCE\_NAME** - The name of the instance AMP needs to create. Should not need to be changed.

These environment variables can either be defined at runtime, as LICENCE has above, or in a file. For information on how to format and use this file, see the [Docker Documentation](https://docs.docker.com/engine/reference/commandline/run/#/set-environment-variables-e-env-env-file).
