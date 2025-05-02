
## Configure local CA certificate

Docker Devbox automatically generates development certificate for HTTPS support, but you need to register the local
CA certificate using mkcert.

#### Linux

Run the following commands from docker devbox shell.

```
# This dependency is required to support Chrome and Firefox.
sudo apt-get install libnss3-tools

# Uninstall any previous CA cert
mkcert -uninstall

# Move to cfssl container directory
cd ~/.docker-devbox/cfssl

# Replace default mkcert key/pair with CFSSL public key.
rm -Rf $(mkcert -CAROOT) && mkdir -p $(mkcert -CAROOT)
docker compose cp intermediate:/etc/cfssl/ca.pem $(mkcert -CAROOT)/rootCA.pem

# Install CFSSL CA Certificate with mkcert.
mkcert -install 
```

#### Windows

On Windows, you should install the CA certificate inside the VM where docker-devbox is installed with the previous
linux procedure, but you should also install the CA certificate on your host, for browser to aknowlegdge the
development certificates.

- Download [mkcert for Windows](https://github.com/FiloSottile/mkcert/releases), and set `CAROOT` environment variable
  to some directory, like `C:\mkcert-ca`.

- Extract the CFSSL ca certificate from docker with the following command

```
# Inside docker-devbox shell
cd ~/.docker-devbox/cfssl
docker compose cp intermediate:/etc/cfssl/ca.pem ../certs/mkcert-ca/rootCA.pem
```

- Copy `~/.docker-devbox/certs/mkcert-ca/rootCA.pem` to the host, inside `CAROOT`
  directory.

- Close all `cmd.exe`, and open a new one to check that `CAROOT` environment variable is defined.

```
# This should output CAROOT environment variable
mkcert -CAROOT
```

- Install CA certificate

```
mkcert -install
```