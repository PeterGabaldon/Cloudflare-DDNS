# Cloudflare DDNS

A minimal bash script that acts as a Dynamic DNS (DDNS) client for Cloudflare. It fetches your current public IPv4 address and updates a Cloudflare DNS A record to point to it — useful for home servers or services behind a dynamic IP.

## How it works

1. Queries `https://ifconfig.me` to obtain your current public IPv4 address.
2. Looks up the target DNS record via the Cloudflare API.
3. Updates the A record with the new IP.

## Prerequisites

- `bash` and `curl`
- A Cloudflare account with a domain managed by Cloudflare
- Your **domain name** managed by Cloudflare (e.g. `mydomain.com`)
- An existing **A record** for the hostname you want to update (e.g. `dyn.mydomain.com`)
- A Cloudflare **API Token** (see below)

## Creating the API Token

Follow these steps to create a token with the **minimum required permissions**:

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens) and click **Create Token**.
2. Click **Get started** next to *Create Custom Token*.
3. Give the token a descriptive name, e.g. `DDNS Updater`.
4. Under **Permissions**, add the following permissions:
   - *Zone* → *Zone* → **Read**
   - *Zone* → *DNS* → **Edit**
5. Under **Zone Resources**, restrict the token to only the zone it needs:
   - *Include* → *Specific zone* → select your domain (e.g. `mydomain.com`)
6. (Optional) Under **Client IP Address Filtering**, you can lock the token to the IP of the machine that will run the script for extra security.
7. Click **Continue to summary**, review, and click **Create Token**.
8. Copy the token value — it will only be shown once.

> **Note:** Do not use a Global API Key. A scoped API token limited to `Zone.Zone Read` + `Zone.DNS Edit` on a single zone is the most secure option.

## Configuration

Open `update-dns.sh` and fill in the three variables at the top:

```bash
ZONE_NAME="mydomain.com"
RECORD_NAME="dyn.mydomain.com"
API_TOKEN="your_cloudflare_api_token"
```

| Variable      | Description                                              |
|---------------|----------------------------------------------------------|
| `ZONE_NAME`   | Your domain name as it appears in Cloudflare             |
| `RECORD_NAME` | The full hostname of the A record to update              |
| `API_TOKEN`   | A Cloudflare API token with DNS edit permissions         |

The script automatically resolves the Cloudflare Zone ID from the domain name at runtime.

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
