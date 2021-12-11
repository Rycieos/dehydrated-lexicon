# dehydrated-lexicon
Docker image to use [dehydrated](https://github.com/dehydrated-io/dehydrated)
and [dns-lexicon](https://github.com/AnalogJ/lexicon) for automated cert
renewal.

This image only contains the basic list of providers supported by dns-lexicon.
The image provided by the dns-lexicon project has support for all providers.

## Usage

Create the container using docker-compose:

```yaml
version: '2.3'
services:
  cert-renewal:
    image: ghcr.io/rycieos/dehydrated-lexicon
    restart: "no"
    volumes:
      - ./domains.txt:/srv/dehydrated/domains.txt:ro
      - ./dehydrated.config:/srv/dehydrated/config:ro
      - /etc/nginx/ssl/:/srv/dehydrated/certs/
      - /etc/nginx/accounts/:/srv/dehydrated/accounts/
    env_file:
      - ./dns-account.env
```

After it runs, it will exit. The container does not contain any cron or
scheduling itself, you should do that through cron on the host machine:

```
 0  5  1  *  * root        docker start my_cert-renewal_1
```

## Configuration

### Domains
See the [dehydrated domains.txt
documentation](https://github.com/dehydrated-io/dehydrated/blob/master/docs/domains_txt.md)
for details.

The file should be mounted in the container at `/srv/dehydrated/domains.txt`.

### Dehydrated config
See the [dehydrated example config
file](https://github.com/dehydrated-io/dehydrated/blob/master/docs/examples/config)
for details.

The file should be mounted in the container at `/srv/dehydrated/config`.

### Certificate output
Mount the directory you want the certificates stored in at
`/srv/dehydrated/certs/`.

### Account storage
ACME providers require accounts to request certificates (even if the account is
free). The account credentals need to be stored externally to the container so
they are not lost on container recreation. Mount a directory for this at
`/srv/dehydrated/accounts/`.

### Lexicon configuration
See the [dns-lexicon environment variables
documentation](https://github.com/dehydrated-io/dehydrated/blob/master/docs/examples/config)
for details on configuring DNS provider credentials.

### Environment variables

#### `PROVIDER`
This variable is required.

Set this to your DNS provider key. See the [dns-lexicon usage
documentation](https://dns-lexicon.readthedocs.io/en/latest/user_guide.html#usage)
for the list of supported DNS providers.

#### DNS_NAMESERVER
Default: 8.8.8.8

An IP address of the DNS nameserver to query when checking if the challenge has
propagated. Most ACME providers will query the authoritative DNS nameservers of
the domain you are signing, so if you set that instead, there will be less time
waiting for propagation.

#### RELOAD_CONTAINER_ID
If set, when a new certificate is obtained, a signal will be sent to the
specified container to tell it to reload. The Docker server socket must be
mounted inside the container for this to work
(`-v /var/run/docker.sock:/tmp/docker.sock:ro`). The Docker socket path can be
configured with `DOCKER_SOCKET`. The reload signal can be configured with
`RELOAD_SIGNAL`.

#### DOCKER_SOCKET
Default: /tmp/docker.sock

The path to the Docker server socket, used to reload a container when a new
certificate is obtained.

#### RELOAD_SIGNAL
Default: SIGHUP

The signal type to send the container to reload it.
