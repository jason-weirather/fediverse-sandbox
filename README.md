# fediverse-sandbox
Spin up multiple activitypub servers to test the fediverse

# Setup a local network for testing Activity Pub servers

1. All domains ending in `*.test` will resolve ports on `127.0.0.1`
2. We will set up a local Certificate Authority for our `*.test` domains

#### Mac OS local network

## 1. Setup `dnsmasq` to resolve domains ending with `.test` on `127.0.0.1`

Install dnsmasq:
```bash
brew install dnsmasq
```

Configure dnsmasq:
```bash
sudo mkdir -p /usr/local/etc
echo "address=/.test/127.0.0.1" | sudo tee /usr/local/etc/dnsmasq.conf
echo 'port=53' >> $(brew --prefix)/etc/dnsmasq.conf
```

Set Up dnsmasq to Start Automatically:
```bash
sudo brew services start dnsmasq
```

Configure macOS to Use dnsmasq for .local Domains:
```bash
sudo mkdir -p /etc/resolver
echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/test
```

Some debugging commands
```bash
sudo brew services restart dnsmasq
sudo killall -HUP mDNSResponder
sudo brew services list


sudo ifconfig en0 down
sudo ifconfig en0 up

```

Check
```bash
scutil --dns
```

And expect to find in it
```yaml
resolver #X
  domain   : test
  nameserver[0] : 127.0.0.1
  flags    : Request A records, Request AAAA records
  reach    : 0x00030002 (Reachable, Local Address, Directly Reachable Address)
```

Explanation:

* `dnsmasq.conf`: The line `address=/.local/127.0.0.1` tells dnsmasq to resolve any domain ending with .local to 127.0.0.1.
* `/etc/resolver/local`: This file tells macOS to use `dnsmasq` (running on 127.0.0.1) for resolving .local domains.

## 2. Set up the local Certificate Authority

Set up a system-based store for our local certs
```bash
mkdir ~/certs
cd ~/certs
```

Generate the private key for the local CA
```bash
openssl genrsa -out myCA.key 2048
```

Generate a self-signed root certificate
```bash
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 365 -out myCA.pem -subj "/CN=MyTestCA"
```

Switch to your `fediverse-sandbox` working directory and make a new certs directory
```bash
mkdir ./certs
cd certs
```

To create individual certificates for each domain 

* `snac1`
```bash
echo "authorityKeyIdentifier=keyid,issuer" > v3_snac1.ext
echo "basicConstraints=CA:FALSE" >> v3_snac1.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> v3_snac1.ext
echo "subjectAltName = @alt_names" >> v3_snac1.ext
echo "[alt_names]" >> v3_snac1.ext
echo "DNS.1 = snac1.test" >> v3_snac1.ext
```

* `ktistec1`
```bash
echo "authorityKeyIdentifier=keyid,issuer" > v3_ktistec1.ext
echo "basicConstraints=CA:FALSE" >> v3_ktistec1.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> v3_ktistec1.ext
echo "subjectAltName = @alt_names" >> v3_ktistec1.ext
echo "[alt_names]" >> v3_ktistec1.ext
echo "DNS.1 = ktistec1.test" >> v3_ktistec1.ext
```

* `ktistec2`
```bash
echo "authorityKeyIdentifier=keyid,issuer" > v3_ktistec2.ext
echo "basicConstraints=CA:FALSE" >> v3_ktistec2.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> v3_ktistec2.ext
echo "subjectAltName = @alt_names" >> v3_ktistec2.ext
echo "[alt_names]" >> v3_ktistec2.ext
echo "DNS.1 = ktistec2.test" >> v3_ktistec2.ext
```

Generate the private key and CSR for each domain
* `snac1`
```bash
openssl genrsa -out snac1.test.key 2048
openssl req -new -key snac1.test.key -out snac1.test.csr -subj "/CN=snac1.test"
```

* `ktistec1`
```bash
openssl genrsa -out ktistec1.test.key 2048
openssl req -new -key ktistec1.test.key -out ktistec1.test.csr -subj "/CN=ktistec1.test"
```

* `ktistec2`
```bash
openssl genrsa -out ktistec2.test.key 2048
openssl req -new -key ktistec2.test.key -out ktistec2.test.csr -subj "/CN=ktistec2.test"
```

Generate the certificates using the CSR and the respective v3.ext file
* `snac1`
```bash
openssl x509 -req -in snac1.test.csr -CA ~/certs/myCA.pem -CAkey ~/certs/myCA.key -CAcreateserial -out snac1.test.crt -days 365 -sha256 -extfile v3_snac1.ext
```

* `ktistec1`
```bash
openssl x509 -req -in ktistec1.test.csr -CA ~/certs/myCA.pem -CAkey ~/certs/myCA.key -CAcreateserial -out ktistec1.test.crt -days 365 -sha256 -extfile v3_ktistec1.ext
```

* `ktistec2`
```bash
openssl x509 -req -in ktistec2.test.csr -CA ~/certs/myCA.pem -CAkey ~/certs/myCA.key -CAcreateserial -out ktistec2.test.crt -days 365 -sha256 -extfile v3_ktistec2.ext
```


Add the `myCA.pem` to Keychain Access

1. Open Keychain Access:

* You can open Keychain Access by going to Applications > Utilities > Keychain Access, or by using Spotlight (Cmd + Space) and typing "Keychain Access."

2. Add the CA Certificate to the Keychain:

* In the Keychain Access menu, go to File > Import Items...
* Navigate to the location of your myCA.pem file and select it for import.
* Choose System as the keychain to import into and click Add.

3. Trust the CA Certificate:

* After importing, locate the myCA.pem certificate in the System keychain.
* Double-click on the certificate to open its properties.
* Expand the "Trust" section.
* Set "When using this certificate" to "Always Trust".
* Close the certificate properties window. You may be prompted to enter your password to confirm the changes.

## Setting up your certs

Create a directory for your certificates if it doesn't already exist:
```bash
mkdir -p ./certs
```

Generate self-signed certificates for each domain:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certs/snac1.test.key -out ./certs/snac1.test.crt -subj "/CN=snac1.test"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certs/ktistec1.test.key -out ./certs/ktistec1.test.crt -subj "/CN=ktistec1.test"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certs/ktistec2.test.key -out ./certs/ktistec2.test.crt -subj "/CN=ktistec2.test"
```

Create a directory structure for the vhost configuration files:
```bash
mkdir -p ./nginx/vhost.d
```

Create a default configuration for your domains in `./nginx/vhost.d/`:
```bash
echo 'proxy_set_header Host $host;' > ./nginx/vhost.d/default
echo 'proxy_set_header X-Real-IP $remote_addr;' >> ./nginx/vhost.d/default
echo 'proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> ./nginx/vhost.d/default
echo 'proxy_set_header X-Forwarded-Proto $scheme;' >> ./nginx/vhost.d/default
```
