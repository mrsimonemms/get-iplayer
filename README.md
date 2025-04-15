# Get iPlayer

Docker container for [Get iPlayer](https://github.com/get-iplayer/get_iplayer)

<!-- toc -->

* [Purpose](#purpose)
* [Contributing](#contributing)
  * [Open in a container](#open-in-a-container)

<!-- Regenerate with "pre-commit run -a markdown-toc" -->

<!-- tocstop -->

## Purpose

This project simplifies getting started with the [Get iPlayer](https://github.com/get-iplayer/get_iplayer)
project by providing a Docker image with it pre-installed. It is tested on
AMD64, ARMv7 and ARM64 architectures.

To use, simply download the Docker image:

```shell
docker run -it --rm -v "/data:/opt/data" ghcr.io/mrsimonemms/get-iplayer
```

This will save any data to the `/data` volume. The entrypoint passes through
any arguments to the `get-iplayer` binary.

## Contributing

### Open in a container

* [Open in a container](https://code.visualstudio.com/docs/devcontainers/containers)
