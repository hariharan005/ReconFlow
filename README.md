# ReconFlow

**ReconFlow** is a modular, Bash-based reconnaissance automation framework for authorized security assessments and bug bounty hunting. It chains together industry-standard OSINT and recon tools into a single guided workflow — from subdomain enumeration to parameter discovery — and organizes every result into a clean, per-target report structure.

```
██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
       Reconnaissance Automation Framework
```

> ⚠️ **Legal Notice:** ReconFlow is intended strictly for authorized security testing — penetration tests, bug bounty programs, and CTFs where you have explicit permission to test the target. Running these modules (especially port scanning and fuzzing) against systems you do not own or have authorization to assess is illegal. Use responsibly.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Recon Workflow](#recon-workflow)
- [Modules](#modules)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Output Structure](#output-structure)
- [Project Structure](#project-structure)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## Overview

ReconFlow wraps well-known open-source recon tools (`subfinder`, `amass`, `httpx`, `nmap`, `ffuf`, `dirsearch`, `katana`, `gau`, `arjun`, and more) into a single interactive CLI menu. Instead of running each tool by hand and manually piping output between them, ReconFlow:

- Takes one domain as input
- Runs each recon stage in the correct order, using the previous stage's output as the next stage's input
- Saves every result into an organized, per-domain report directory
- Lets you run the full pipeline end-to-end, or trigger individual modules on demand

## Features

- 🎯 **Single-target workflow** — enter a domain once, run any/all modules against it
- 🧩 **Modular architecture** — each recon stage lives in its own script under `modules/`, easy to extend or swap out
- 🔗 **Automatic data chaining** — subdomains → live hosts → ports/directories/URLs/parameters, without manual file handling
- 📁 **Organized reporting** — all output is written to `reports/<domain>/`, separated by tool and stage
- 🖥️ **Interactive menu** — run the full pipeline (`Run Complete Recon`) or jump straight to a specific stage
- 🔄 **Re-runnable** — switch targets or re-run any module at any time without restarting the tool
- ⚙️ **One-shot installer** — `install.sh` provisions every external dependency the modules rely on

## Recon Workflow

ReconFlow follows a linear pipeline where each stage feeds the next:

```
Domain Input
     │
     ▼
Subdomain Enumeration  (subfinder, assetfinder, amass)
     │
     ▼
HTTPX Recon            (httpx — filters live hosts, detects tech/status/title)
     │
     ├──▶ Basic Information   (nmap -sL, dig — IPs & DNS records)
     ├──▶ IP Getter           (nmap -sL — resolves IPs for all live hosts)
     ├──▶ Port Scanner        (nmap -p- -sV -sC -O — full TCP + service/OS detection)
     ├──▶ Directory Enum      (dirsearch, ffuf — dirs, files, backups, API, GraphQL)
     ├──▶ Crawling            (hakrawler, katana, gospider, gau — URL discovery)
     └──▶ Parameter Discovery (gau, waybackurls, katana, ParamSpider, Arjun)
```

Everything downstream of **HTTPX Recon** depends on `httpx_live_subdomains.txt`, so that module must be run at least once before the others.

## Modules

| # | Module | Script | Tools Used | Purpose |
|---|--------|--------|------------|---------|
| 1 | Subdomain Enumeration | `modules/subdomain_recon.sh` | `subfinder`, `assetfinder`, `amass` | Discover subdomains and de-duplicate results |
| 2 | HTTPX Recon | `modules/httpx.sh` | `httpx` | Probe subdomains for live hosts; capture status code, title, tech stack, server, and IP |
| 3 | Basic Information | `modules/Basic_Info.sh` | `nmap`, `dig` | Resolve IPs and pull DNS records (A, AAAA, MX, NS, TXT, CNAME, SOA) per host |
| 4 | IP Getter | `modules/Ip_Getter.sh` | `nmap -sL` | Map every live subdomain to its resolved IP address |
| 5 | Port Scanner | `modules/Port_Scanner.sh` | `nmap -p- -sV -sC -O` | Full-range TCP port scan with service, script, and OS detection |
| 6 | Directory Enumeration | `modules/Dir_Enum.sh` | `dirsearch`, `ffuf` | Discover directories, files, backups, API endpoints, GraphQL paths, and extensions |
| 7 | Crawling | `modules/Crawling.sh` | `hakrawler`, `katana`, `gospider`, `gau` | Crawl live hosts and harvest URLs from multiple sources |
| 8 | Parameter Discovery | `modules/Parameter_Discovery.sh` | `gau`, `waybackurls`, `katana`, `paramspider`, `arjun` | Harvest parameterized URLs and discover hidden HTTP parameters |

## Requirements

ReconFlow targets **Debian/Kali-based Linux** systems and expects `apt-get` to be available.

**System:**
- Bash
- `sudo` privileges (required for `nmap` OS detection, `apt` installs, and full port scans)

**External tools** (all installed automatically by `install.sh`):

| Category | Tools |
|----------|-------|
| APT packages | `nmap`, `dnsutils`, `git`, `curl`, `wget`, `golang-go`, `python3`, `python3-pip`, `python3-venv`, `pipx`, `build-essential`, `seclists`, `amass`, `ffuf`, `hakrawler`, `gospider` |
| Go tools | `subfinder`, `assetfinder`, `httpx`, `katana`, `gau`, `waybackurls` |
| Python (pipx) tools | `dirsearch`, `arjun`, `paramspider` |
| Wordlists | [SecLists](https://github.com/danielmiessler/SecLists) (`/usr/share/seclists`) |

## Installation

Clone the repository and run the installer, which provisions every dependency listed above:

```bash
git clone https://github.com/hariharan005/ReconFlow.git
cd ReconFlow
chmod +x install.sh main.sh
./install.sh
```

The installer:
- Installs all required `apt` packages
- Installs Go-based tools via `go install` and adds `$GOPATH/bin` to your shell `PATH`
- Installs Python-based tools via `pipx`
- Clones SecLists if not already present on the system
- Prints a summary of what installed successfully and what needs manual attention
- Is safe to re-run — already-installed tools are skipped unless you pass `--force`

```bash
./install.sh --force   # force-reinstall every tool
```

After installation, open a new shell (or `source ~/.zshrc` / `source ~/.bashrc`) so `PATH` updates take effect.

## Usage

Run the main script and follow the interactive menu:

```bash
./main.sh
```

You'll first be prompted for a target domain:

```
Enter the Domain Name: example.com
```

Then the main menu appears:

```
==========================================
              ReconFlow Menu
==========================================

Target : example.com

 1. Subdomain Enumeration
 2. HTTPX Recon
 3. Basic Information
 4. IP Getter
 5. Port Scanner
 6. Directory Enumeration
 7. Crawling
 8. Parameter Discovery
 9. Run Complete Recon
 10. Change Target Domain
 11. Exit
```

- Choose **1–8** to run an individual module
- Choose **9** to run the entire pipeline end-to-end, in order
- Choose **10** to switch targets without restarting the script
- Choose **11** to exit

**Recommended first run:** run option `1` (Subdomain Enumeration) then `2` (HTTPX Recon) before anything else — every other module reads from the live-hosts file that HTTPX Recon produces.

## Output Structure

All results are written under `reports/<domain_name>/`:

```
reports/example.com/
├── Subdomains.txt                  # Raw + merged subdomain list
├── httpx_results.txt               # Full httpx output (status, title, tech, server, IP)
├── httpx_live_subdomains.txt       # Clean list of live hosts (input for all later stages)
├── Basic_Info.txt                  # Per-host IP + DNS records
├── alldomain-ip.txt                # Host → IP mapping
├── port_scan_results.txt           # nmap full port/service/OS scan
├── Dirsearch/                      # Per-host dirsearch output
├── FFUF/
│   └── <host>/
│       ├── directories.json
│       ├── files.json
│       ├── backups.json
│       ├── api.json
│       ├── graphql.json
│       └── extensions.json
├── hakrawler-urls.txt
├── urls.txt                        # katana output
├── gospider-urls/
├── gau-urls.txt
└── Parameter_Discovery/
    ├── gau/
    ├── waybackurls/
    ├── katana/
    ├── paramspider/
    ├── arjun/
    ├── all_parameter_urls.txt      # merged, de-duplicated URLs
    └── parameter_urls.txt          # URLs containing query parameters
```

## Project Structure

```
ReconFlow/
├── main.sh                     # Entry point — menu-driven orchestrator
├── install.sh                  # Dependency installer for all external tools
├── LICENSE
├── README.md
└── modules/
    ├── Banner.sh                # Startup banner
    ├── subdomain_recon.sh       # Module 1
    ├── httpx.sh                 # Module 2
    ├── Basic_Info.sh             # Module 3
    ├── Ip_Getter.sh              # Module 4
    ├── Port_Scanner.sh           # Module 5
    ├── Dir_Enum.sh                # Module 6
    ├── Crawling.sh                # Module 7
    └── Parameter_Discovery.sh    # Module 8
```

## Disclaimer

ReconFlow is provided for educational purposes and **authorized** security testing only (penetration tests, bug bounty programs, CTFs, or systems you own). The author is not responsible for any misuse of this tool. Always obtain explicit, written authorization before scanning a target.

## License

Licensed under the [MIT License](LICENSE).

---

**Author:** Hariharan C
