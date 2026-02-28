# PhoenixGym – Deployment Plan (Cheapest / Free)

This guide covers deploying PhoenixGym as a **single user** at the **lowest cost**, using either **Railway** or **AWS**. Both accounts are supported.

---

## Cost comparison (single user)

| Option | Cost | Best for |
|--------|------|----------|
| **Railway (recommended)** | **$5/month** (Hobby plan; includes $5 usage) | Easiest setup, predictable cost |
| **Railway (free trial)** | **$0** for ~1 month | Try before paying (one-time $5 credit) |
| **AWS Free Tier** | **$0** for first 12 months | Free for a year, more manual setup |
| **AWS after free tier** | ~\$10–15/month (EC2 + DB) or ~\$3.50 (Lightsail) | After 12 months |

**Recommendation:** Use **Railway** for simplicity (~$5/month). Use **AWS Free Tier** if you want **$0 for 12 months** and are okay with more steps.

---

# Option A: Deploy on Railway (easiest, ~$5/month)

Railway runs your app and Postgres, handles builds and HTTPS. Hobby plan is $5/month and includes $5 of usage, which is enough for a single-user Phoenix app + Postgres.

## Step 1: Prepare the app for Railway

### 1.1 Ensure `nixpacks.toml` exists in the project root

The project already includes a `nixpacks.toml` in the root (same level as `mix.exs`). It tells Railway how to build and run your Phoenix app. If you need to recreate it, use:

```toml
[variables]
MIX_ENV = "prod"

[phases.install]
cmds = [
  "mix local.hex --force",
  "mix local.rebar --force",
  "mix deps.get --only prod"
]

[phases.build]
cmds = [
  "mix assets.deploy",
  "mix compile"
]

[start]
cmd = "mix ecto.migrate && mix phx.server"
```

This tells Railway how to build and run your Phoenix app and run migrations on startup.

### 1.2 Generate a secret key

On your machine, in the project directory, run:

```bash
mix phx.gen.secret
```

Copy the output; you will use it as `SECRET_KEY_BASE` on Railway.

### 1.3 Push code to GitHub

If the app is not on GitHub yet:

```bash
git add .
git commit -m "Prepare for Railway deployment"
git remote add origin https://github.com/YOUR_USERNAME/phoenixgym.git
git push -u origin main
```

Use your real GitHub username and repo URL.

---

## Step 2: Create the project on Railway

1. Go to [railway.com](https://railway.com) and log in.
2. Click **“Start a New Project”** (or **“New Project”**).
3. Choose **“Deploy from GitHub repo”**.
4. Connect GitHub if asked, then select the **phoenixgym** repository.
5. Railway will create a new **service** for the app. Wait for the first build; it may fail until you add the database and variables.

---

## Step 3: Add PostgreSQL

1. In the same project, click **“+ New”** (or **“Add Service”**).
2. Choose **“Database”** → **“PostgreSQL”**.
3. Wait until Postgres is provisioned. Railway will set a `DATABASE_URL` variable for this service.

---

## Step 4: Configure environment variables

1. Open your **Phoenix app service** (the one from the GitHub repo), not the Postgres service.
2. Go to the **Variables** tab.
3. Add (or edit) these variables:

| Variable | Value |
|----------|--------|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` (reference to the Postgres service; use the exact name shown in Railway, e.g. `Postgres`) |
| `SECRET_KEY_BASE` | The value from `mix phx.gen.secret` (Step 1.2) |
| `PHX_HOST` | Your public hostname, e.g. `phoenixgym.up.railway.app` (you’ll get this in Step 5) |
| `ECTO_IPV6` | `true` (so the app can reach Postgres over Railway’s network) |
| `LANG` | `en_US.UTF-8` |
| `LC_CTYPE` | `en_US.UTF-8` |

Railway sets `PORT` automatically; your `config/runtime.exs` already uses it.

---

## Step 5: Get a public URL

1. In the **Phoenix app service**, open **Settings** → **Networking** (or **Variables** / **Networking**).
2. Click **“Generate Domain”** (or **“Add public URL”**).
3. Copy the generated hostname (e.g. `phoenixgym-production-xxxx.up.railway.app`).
4. Set **`PHX_HOST`** in Variables to this hostname (no `https://`), then save.
5. Redeploy the app so the new `PHX_HOST` is applied (e.g. **Deploy** → **Redeploy** or push a new commit).

---

## Step 6: Deploy and check

1. Trigger a deploy (push a commit or use **Redeploy**).
2. In the app service, open **“Logs”** (or **Deployments** → latest deploy → logs).
3. Confirm you see something like “Running migrations” and that the server starts without errors.
4. Open the generated URL in the browser (HTTPS is provided by Railway).

---

## Step 7: (Optional) Custom domain

If you have a domain (e.g. from Route 53 or another registrar):

1. In the app service → **Settings** → **Networking**, add your custom domain.
2. Follow Railway’s instructions to set the CNAME (or A/AAAA) at your DNS provider.
3. Set **`PHX_HOST`** to your custom domain (e.g. `app.yourdomain.com`) and redeploy.

---

## Railway cost summary

- **Free trial:** One-time $5 credit when you sign up (~1 month for a small app).
- **Hobby plan:** $5/month, includes $5 usage. For one user and one app + Postgres, you usually stay within that.
- **Billing:** Add a payment method in **Account** → **Billing**. Without it, you can only use the trial credit.

---

# Option B: Deploy on AWS Free Tier ($0 for 12 months)

This uses **EC2** (one small instance) and **PostgreSQL on the same instance** to stay within the free tier. After 12 months, you can keep the same setup (paid) or move to something like Lightsail (~\$3.50/month).

**Free tier (12 months):**

- **EC2:** 750 hours/month of `t2.micro` (1 vCPU, 1 GB RAM).
- **EBS:** 30 GB storage.
- One `t2.micro` running 24/7 fits within these limits.

---

## Step 1: Launch an EC2 instance

1. Log in to [AWS Console](https://console.aws.amazon.com/) and open **EC2**.
2. **Region:** Choose a region (e.g. `us-east-1`) and stick to it.
3. **Launch instance:**
   - **Name:** e.g. `phoenixgym`.
   - **AMI:** **Ubuntu Server 24.04 LTS** (free tier eligible).
   - **Instance type:** **t2.micro** (free tier).
   - **Key pair:** Create or select an SSH key and **download** the `.pem` file. You need it to connect.
   - **Network / Security group:** Create or edit so that:
     - **SSH (22)** – Your IP only (or your home IP).
     - **HTTP (80)** – `0.0.0.0/0`.
     - **HTTPS (443)** – `0.0.0.0/0`.
     - **Custom TCP 4000** – `0.0.0.0/0` (optional; only if you test on port 4000 before adding a reverse proxy).
   - **Storage:** 20–30 GB (stays in free tier).
4. Launch the instance and note its **Public IPv4 address**.

---

## Step 2: Install dependencies on the server

SSH into the instance (replace `KEY.pem` and `EC2_IP`):

```bash
chmod 400 KEY.pem
ssh -i KEY.pem ubuntu@EC2_IP
```

Then run (one block or line by line):

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git curl unzip postgresql postgresql-contrib
```

Install Erlang and Elixir (adjust version if needed):

```bash
curl -sL https://github.com/asdf-vm/asdf/archive/refs/tags/v0.14.0.tar.gz | tar -xz -C ~
echo '. "$HOME/asdf-0.14.0/asdf.sh"' >> ~/.bashrc
source ~/.bashrc
asdf plugin add erlang
asdf plugin add elixir
asdf install erlang 26.2.2
asdf install elixir 1.16.1-otp-26
asdf global erlang 26.2.2
asdf global elixir 1.16.1-otp-26
```

Install Node.js (for assets):

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

---

## Step 3: PostgreSQL on the same instance

```bash
sudo -u postgres createuser -s phoenixgym
sudo -u postgres psql -c "ALTER USER phoenixgym WITH PASSWORD 'CHOOSE_A_STRONG_PASSWORD';"
sudo -u postgres createdb -O phoenixgym phoenixgym_prod
```

Replace `CHOOSE_A_STRONG_PASSWORD` with a real password. You’ll use it in `DATABASE_URL`.

---

## Step 4: Build a release on your machine

On your **local** machine (with Elixir and Node installed), from the project root:

```bash
# Install release generator if you haven't yet
mix phx.gen.release

# Build assets and release
export MIX_ENV=prod
mix deps.get --only prod
mix assets.deploy
mix release
```

This creates (or updates) `_build/prod/rel/phoenixgym`. You’ll copy this to the server, or build on the server (see below).

---

## Step 5: Deploy the release to EC2

**Option 5a – Copy release from your machine (simplest for one server):**

From your **local** machine (replace paths and EC2_IP):

```bash
# From project root
scp -i KEY.pem -r _build/prod/rel/phoenixgym ubuntu@EC2_IP:~/
scp -i KEY.pem rel/env.sh.eex ubuntu@EC2_IP:~/
```

**Option 5b – Build on the server:**

On the server, clone the repo and build there (then you can use GitHub Actions or a script to pull and rebuild later):

```bash
cd ~
git clone https://github.com/YOUR_USERNAME/phoenixgym.git
cd phoenixgym
export MIX_ENV=prod
mix local.hex --force && mix local.rebar --force
mix deps.get --only prod
mix assets.deploy
mix release
```

---

## Step 6: Configure and run the app on EC2

On the **server**, create an env file (e.g. `~/phoenixgym.env`) with real values:

```bash
export PHX_HOST=YOUR_EC2_PUBLIC_IP_or_DOMAIN
export SECRET_KEY_BASE=GENERATE_WITH_mix_phx_gen_secret
export DATABASE_URL=ecto://phoenixgym:CHOOSE_A_STRONG_PASSWORD@localhost/phoenixgym_prod
export PORT=4000
```

Then run migrations and start the app:

```bash
source ~/phoenixgym.env
~/phoenixgym/bin/phoenixgym eval "Phoenixgym.Release.migrate"
~/phoenixgym/bin/phoenixgym start
```

Or use the generated `bin/server` if you used `mix phx.gen.release` and it created a start script.

To run in the background (e.g. with `systemd`):

```bash
sudo nano /etc/systemd/system/phoenixgym.service
```

Content (adjust paths and user):

```ini
[Unit]
Description=PhoenixGym
After=network.target postgresql.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
EnvironmentFile=/home/ubuntu/phoenixgym.env
ExecStart=/home/ubuntu/phoenixgym/bin/phoenixgym start
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable phoenixgym
sudo systemctl start phoenixgym
sudo systemctl status phoenixgym
```

---

## Step 7: (Optional) HTTPS with Caddy

To serve on port 80/443 with automatic HTTPS, install Caddy on the server:

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy
sudo systemctl enable caddy
```

Create `/etc/caddy/Caddyfile`:

```
YOUR_DOMAIN_OR_EC2_PUBLIC_IP {
    reverse_proxy localhost:4000
}
```

If you don’t have a domain, you can use the EC2 public IP; you’ll get a self-signed cert or use HTTP only. Then:

```bash
sudo systemctl reload caddy
```

Set **`PHX_HOST`** to the same host you use in the browser (domain or IP).

---

## Step 8: Open the app

- If you didn’t set up Caddy: `http://EC2_IP:4000`
- If you set up Caddy: `https://YOUR_DOMAIN` or `http://EC2_IP`

---

## AWS cost summary

- **Months 1–12:** $0 if you use only one `t2.micro`, stay in one region, and use only free tier EBS.
- **After 12 months:** You’ll be charged for EC2 and EBS (roughly ~\$10–15/month for this setup) unless you stop the instance or switch to something like Lightsail (~\$3.50/month for a small instance).

---

# Checklist before going live

- [ ] **SECRET_KEY_BASE** is set and never committed.
- [ ] **DATABASE_URL** uses a strong password and (on AWS) is not exposed publicly.
- [ ] **PHX_HOST** matches the URL users will use (Railway domain or AWS domain/IP).
- [ ] Migrations run on deploy (Railway: in `nixpacks.toml` start command; AWS: in systemd or manual step).
- [ ] (Optional) Custom domain and HTTPS (Railway does HTTPS by default; on AWS use Caddy or similar).

---

# Quick reference

| Task | Railway | AWS |
|------|---------|-----|
| **Cost (single user)** | $5/month (Hobby) or trial $5 credit | $0 for 12 months, then ~\$10–15 or Lightsail ~\$3.50 |
| **Setup time** | ~15–30 min | ~1–2 hours |
| **Database** | Railway Postgres (included) | Postgres on same EC2 |
| **HTTPS** | Automatic | Caddy or Nginx + Let’s Encrypt |
| **Updates** | Push to GitHub → auto deploy | SSH + pull/build or CI/CD |

If you want to minimize cost and don’t mind more setup, use **AWS Free Tier**. If you want the simplest path and predictable cost, use **Railway** ($5/month).
