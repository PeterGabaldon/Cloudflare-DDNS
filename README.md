# Cloudflare DDNS

A minimal bash script that acts as a Dynamic DNS (DDNS) client for Cloudflare. It fetches your current public IPv4 address and updates a Cloudflare DNS A record to point to it — useful for home servers or services behind a dynamic IP.

## How it works

1. Queries `https://ifconfig.me` to obtain your current public IPv4 address.
2. Looks up the target DNS record via the Cloudflare API.
3. Updates the A record with the new IP.

## Prerequisites

- `bash` and `curl`
- A Cloudflare account with a domain managed by Cloudflare
- A Cloudflare **API Token** with `Zone.DNS` edit permissions ([create one here](https://dash.cloudflare.com/profile/api-tokens))
- The **Zone ID** of your domain (found on the domain's overview page in the Cloudflare dashboard)
- An existing **A record** for the hostname you want to update (e.g. `dyn.mydomain.com`)

## Configuration

Open `update-dns.sh` and fill in the three variables at the top:

```bash
ZONE_ID="your_zone_id"
RECORD_NAME="dyn.mydomain.com"
API_TOKEN="your_cloudflare_api_token"
```

| Variable      | Description                                           |
|---------------|-------------------------------------------------------|
| `ZONE_ID`     | The Zone ID from your Cloudflare domain overview page |
| `RECORD_NAME` | The full hostname of the A record to update           |
| `API_TOKEN`   | A Cloudflare API token with DNS edit permissions      |

## Usage

```bash
chmod +x update-dns.sh
./update-dns.sh
```

On success you'll see:

```
Updated dyn.mydomain.com -> 203.0.113.42
```

### Automate with cron

To run every 5 minutes:

```bash
crontab -e
```

Add:

```
*/5 * * * * /path/to/update-dns.sh >> /var/log/cloudflare-ddns.log 2>&1
```
