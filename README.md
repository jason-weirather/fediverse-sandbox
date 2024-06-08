# fediverse-sandbox
*Spin up multiple ActivityPub servers to test the Fediverse*

The fediverse-sandbox project provides a local testing environment for experimenting with multiple ActivityPub servers. This setup allows developers to test Fediverse interactions between different servers on a single machine using Docker Compose, `dnsmasq` for local DNS resolution, and self-signed certificates for HTTPS.

## Setup a Local Network for Testing ActivityPub Servers

### Prerequisites

*MacOS*

1. **Docker** and **Docker Compose** installed on your system.
2. **Homebrew** installed on macOS for managing packages.
3. **Keychain Access** for managing certificates on macOS.

### 1. Configure DNS Resolution on localhost with `dnsmasq`

Install `dnsmasq`:
```bash
brew install dnsmasq
```

Configure `dnsmasq` to resolve `.test` domains:
*These are not valid public domains so you should not encounter them on the public interent.*
```bash
sudo mkdir -p /usr/local/etc
echo "address=/.test/127.0.0.1" | sudo tee /usr/local/etc/dnsmasq.conf
echo 'port=53' >> $(brew --prefix)/etc/dnsmasq.conf
```

Start `dnsmasq` automatically:
```bash
sudo brew services start dnsmasq
```

Configure macOS to Use `dnsmasq` for `.test` Domains:
```bash
sudo mkdir -p /etc/resolver
echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/test
```

Verify the configuration:
```bash
scutil --dns
```

Ensure your configuration looks like:
```yaml
resolver #X
  domain   : test
  nameserver[0] : 127.0.0.1
  flags    : Request A records, Request AAAA records
  reach    : 0x00030002 (Reachable, Local Address, Directly Reachable Address)
```

Some debugging commands that may be useful:
```bash
sudo brew services restart dnsmasq
sudo killall -HUP mDNSResponder
sudo brew services list
sudo ifconfig en0 down
sudo ifconfig en0 up
```

### 2. Set up the local Certificate Authority

Create a directory for storing your local certificate authority (CA):
```bash
mkdir ~/certs
cd ~/certs
```

Generate the private key for the local CA:
```bash
openssl genrsa -out myCA.key 2048
```

Generate a self-signed root certificate:
```bash
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 365 -out myCA.pem -subj "/CN=MyTestCA"
```

Add the `myCA.pem` to Keychain Access:

1. Open Keychain Access (Applications > Utilities > Keychain Access, or use Spotlight).
2. Go to File > Import Items..., select myCA.pem, choose System as the keychain, and click Add.
3. Locate myCA.pem in the System keychain, double-click to open properties, expand the "Trust" section, set "When using this certificate" to "Always Trust", and close the properties window (enter your password to confirm).

### 3. Generate certificates for your `fediverse-sandbox` project

Switch to the `fediverse-sandbox` project directory and create a `certs` directory:
```bash
cd fediverse-sandbox
mkdir -p ./certs
cp ~/certs/myCA.pem ./certs/myCA.pem
```

Switch to your certs directory
```bash
cd ./certs
```

Create configuration files and generate certificates for each domain:

**`snac1`**
```bash
echo "authorityKeyIdentifier=keyid,issuer" > v3_snac1.ext
echo "basicConstraints=CA:FALSE" >> v3_snac1.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> v3_snac1.ext
echo "subjectAltName = @alt_names" >> v3_snac1.ext
echo "[alt_names]" >> v3_snac1.ext
echo "DNS.1 = snac1.test" >> v3_snac1.ext

openssl genrsa -out snac1.test.key 2048
openssl req -new -key snac1.test.key -out snac1.test.csr -subj "/CN=snac1.test"

openssl x509 -req -in snac1.test.csr -CA ~/certs/myCA.pem -CAkey ~/certs/myCA.key -CAcreateserial -out snac1.test.crt -days 365 -sha256 -extfile v3_snac1.ext
```

**`ktistec1`**
```bash
echo "authorityKeyIdentifier=keyid,issuer" > v3_ktistec1.ext
echo "basicConstraints=CA:FALSE" >> v3_ktistec1.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> v3_ktistec1.ext
echo "subjectAltName = @alt_names" >> v3_ktistec1.ext
echo "[alt_names]" >> v3_ktistec1.ext
echo "DNS.1 = ktistec1.test" >> v3_ktistec1.ext

openssl genrsa -out ktistec1.test.key 2048
openssl req -new -key ktistec1.test.key -out ktistec1.test.csr -subj "/CN=ktistec1.test"

openssl x509 -req -in ktistec1.test.csr -CA ~/certs/myCA.pem -CAkey ~/certs/myCA.key -CAcreateserial -out ktistec1.test.crt -days 365 -sha256 -extfile v3_ktistec1.ext
```

**`ktistec2`**
```bash
echo "authorityKeyIdentifier=keyid,issuer" > v3_ktistec2.ext
echo "basicConstraints=CA:FALSE" >> v3_ktistec2.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> v3_ktistec2.ext
echo "subjectAltName = @alt_names" >> v3_ktistec2.ext
echo "[alt_names]" >> v3_ktistec2.ext
echo "DNS.1 = ktistec2.test" >> v3_ktistec2.ext

openssl genrsa -out ktistec2.test.key 2048
openssl req -new -key ktistec2.test.key -out ktistec2.test.csr -subj "/CN=ktistec2.test"

openssl x509 -req -in ktistec2.test.csr -CA ~/certs/myCA.pem -CAkey ~/certs/myCA.key -CAcreateserial -out ktistec2.test.crt -days 365 -sha256 -extfile v3_ktistec2.ext
```

### 4. Configure fediverse servers

**`snac1`**

Generate and show new passwords:
```bash
bash utilities/reset_and_get_snac_passwords.sh
```
