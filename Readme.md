# Minecraft AMP
A dockerfile for using the Minecraft module of the AMP server management program, by CubeCoders.

## Environment Variables
This Dockerfile requires a CubeCoders licence, specified as the environment variable LICENCE. An example run command for this Dockerfile is:

```docker run -d -e "LICENCE=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" -p 8080:8080  -p 25565:25565 -v /volumes/amp:/ampdata adamant/minecraft-amp```

To rebind the port the Minecraft server listens on, simply replace the first intance of 25565 with the external port.

This dockerfile also support more environment variables to customise the minecraft servere parameters. These are:
* **HOST** - Specifies the interface AMP and the minecraft server should listen on
* **PORT** - The port for the AMP webUI
* **USERNAME** - The default username for logging into the webUI
* **PASSWORD** - The default password for logging into the webUI
* **INSTANCE_NAME** - The name of the instance AMP needs to create. Should not need to be changed.

These environment variables can either be defined at runtime, as LICENCE has above, or in a file. For information on how to format and use this file, see the [Docker Docs](https://docs.docker.com/engine/reference/commandline/run/#/set-environment-variables-e-env-env-file).
