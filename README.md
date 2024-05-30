# fediverse-sandbox
Spin up multiple activitypub servers to test the fediverse

### For a local test set up domains ending with .local to resolve to `127.0.0.1`

#### Mac OS local network

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

## Setting up your certs

Create a directory for your certificates if it doesn't already exist:
```bash
mkdir -p ./certs
```

Generate self-signed certificates for each domain:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certs/snac1.test.key -out ./certs/snac1.test.crt -subj "/CN=snac1.test"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certs/snac2.test.key -out ./certs/snac2.test.crt -subj "/CN=snac2.test"
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
