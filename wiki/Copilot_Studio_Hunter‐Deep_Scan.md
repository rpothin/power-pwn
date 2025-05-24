# Modules: Copilot Studio Hunter ‐ Deep Scan

## Description
Conducts deep scanning to find open Copilot Studio bots based on domains or tenant IDs using an automation which utilizes different Copilot Studio & Power Platform mechanics and the Power Platform API, FFUF and Puppeteer.

## Additional Installation Notes
1. Requires [FFUF](https://github.com/ffuf/ffuf) and [Puppeteer](https://github.com/puppeteer/puppeteer) to be installed and to exist within the path as a prerequisite. Please see the attached links for the installations.
2. Note that Puppeteer might need to be installed locally via the local Puppeteer project directory: 
    - Locate the internal Puppeteer directory (under the _src_ -> _powerpwn_ -> _copilot_studio_ -> _tools_ -> _pup_is_webchat_live_ directory)
    - Run `npm install`
3. For Windows machines running this module, it's recommended to have a Chrome installation in the default location (C:\Program Files\Google\Chrome\Application\chrome.exe).

## Prerequisites Validation

Before running the deep scan, validate that all required tools are properly installed and accessible:

```bash
#!/bin/bash
echo "=== PowerPwn Copilot Studio Hunter - Prerequisites Check ==="

# Make the script executable (if you haven't already)
chmod +x check_prereqs.sh

# Run the script
./check_prereqs.sh
```

## Usage
### powerpwn cli
* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a domain:<br>
`powerpwn copilot-studio-hunter deep-scan -d {domain} -t {no. of FFUF threads} -r {no. of FFUF requests per second} --mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a tenant ID:<br>
`powerpwn copilot-studio-hunter deep-scan -i {tenant ID} -t {no. of FFUF threads} -r {no. of FFUF requests per second} --mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

### Command Parameters
* **domain**: The domain to query for tenant ID and run FFUF on
* **tenant_id**: The tenant ID to run FFUF on 
* **rate**: Rate limit in seconds between FFUF requests
* **threads**: Number of concurrent FFUF threads
* **timeout_prefix**: The timeout for the solution prefix scan to have, in seconds (default is 5 minutes)
* **timeout_bots**: The timeout for each of the bot scans (one-word/two-word/three-word) to have, in seconds (default is 5 minutes)
* **mode**: Choose between verbose (-v) and silent (-s) mode for FFUF

## Usage Examples

### Bash Example with Domain Variable
```bash
#!/bin/bash

# Example command to perform a deep scan based on a domain:
powerpwn copilot-studio-hunter deep-scan -d "contoso.com" -t 10 -r 50 --mode "verbose" -tp 300 -tb 300
```

### Bash Example with Tenant ID Variable
```bash
#!/bin/bash

# Example command to perform a deep scan based on a tenant ID:
powerpwn copilot-studio-hunter deep-scan -i "11111111-1111-1111-1111-111111111111" -t 10 -r 50 --mode "verbose" -tp 300 -tb 300
```

### Parameter Value Guidelines

| Parameter      | Recommended Values | Description                   |
| -------------- | ------------------ | ----------------------------- |
| threads        | 5-20               | Concurrency level             |
| rate           | 10-100             | Requests per second           |
| mode           | verbose or silent  | Verbosity level               |
| timeout_prefix | 300-600            | Prefix scan timeout (seconds) |
| timeout_bots   | 300-900            | Bot scan timeout (seconds)    |

### Output exploitation

Once the `deep-scan` module completes, it generates multiple files across different directories within the copilot studio folder structure. Understanding these outputs is crucial for effective exploitation and analysis.

#### Generated File Structure

The deep scan creates files in two main directories:

1. **Final Results** (`src/powerpwn/copilot_studio/final_results/`)
2. **Internal Results** (`src/powerpwn/copilot_studio/internal_results/`)

#### Final Results Directory

The final results contain the consolidated findings from the deep scan:

| File Type | Example Name                               | Description                                   |
| --------- | ------------------------------------------ | --------------------------------------------- |
| XLSX      | `YOUR_DOMAIN_OR_TENANT_ID_YYYY_MM_DD.xlsx` | Structured Excel report with scan summary     |
| JSON      | `YOUR_DOMAIN_OR_TENANT_ID_YYYY_MM_DD.json` | Auto-generated JSON version of the Excel data |
| TXT       | `chat_exists_output.txt`                   | Log file for chat existence validation        |

**JSON Structure Example:**
```json
[
    {
        "Domain": "contoso.com",
        "Tenant default environment found?": "11111111-1111-1111-1111-111111111111",
        "Default Solution Prefix found?": "abc123",
        "No. of existing bots found": 1,
        "No. of open bots found": 0,
        "Existing Bots": "Sample Bot"
    }
]
```

#### Internal Results Directory Structure

The internal results provide detailed technical data for deeper analysis:

```
internal_results/
├── ffuf_results/
│   ├── ffuf_results_DOMAIN.csv                    # Main FFUF scan results
│   ├── ffuf_results_DOMAIN_one_word_names.csv     # Single-word bot name results
│   └── ffuf_results_DOMAIN_two_word_names.csv     # Two-word bot name results
├── prefix_fuzz_values/
│   └── fuzz1_value_DOMAIN.txt                     # Discovered solution prefixes
└── url_results/
    └── url_output_DOMAIN.txt                      # Direct bot URLs found
```

#### File Analysis and Conversion

##### Converting XLSX to JSON

To convert the Excel report to JSON format, use the following commands:

```bash
# Install dependencies (if not already installed, also covered in check_prereqs.sh)
pip install pandas openpyxl

# Convert the XLSX file to JSON (output in the same directory)
python /workspaces/power-pwn/xlsx_to_json.py /workspaces/power-pwn/src/powerpwn/copilot_studio/final_results/YOUR_DOMAIN_OR_TENANT_ID_YYYY_MM_DD.xlsx

# Example:
# python /workspaces/power-pwn/src/powerpwn/copilot_studio/final_results/contoso.com_YYYY_MM_DD.xlsx

# Optional: Specify a different output path for the JSON file
# python /workspaces/power-pwn/xlsx_to_json.py /path/to/your/input.xlsx /path/to/your/output.json
```

##### Analyzing FFUF Results

The CSV files in `ffuf_results/` contain detailed fuzzing data with the following structure:

| Column         | Description                     |
| -------------- | ------------------------------- |
| FUZZ1          | Solution prefix                 |
| FUZZ2          | Bot name part 1                 |
| FUZZ3          | Bot name part 2 (if applicable) |
| FUZZ4          | Bot name part 3 (if applicable) |
| url            | Target API endpoint             |
| status_code    | HTTP response code              |
| content_length | Response size                   |

```bash
# View FFUF results for successful discoveries (HTTP 200)
grep ",200," /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/ffuf_results/ffuf_results_YOUR_DOMAIN.csv

# Extract unique bot names found
awk -F',' '$10=="200" {print $2$3$4}' /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/ffuf_results/ffuf_results_YOUR_DOMAIN.csv | sort -u
```

##### Extracting Exploitation Data

```bash
# Get all discovered Copilot Studio URLs
cat /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/url_results/url_output_YOUR_DOMAIN.txt

# Get solution prefixes for further reconnaissance
cat /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/prefix_fuzz_values/fuzz1_value_YOUR_DOMAIN.txt

# Create a comprehensive report combining all findings
echo "=== Deep Scan Results Summary ===" > scan_summary.txt
echo "Domain/Tenant: YOUR_DOMAIN" >> scan_summary.txt
echo "" >> scan_summary.txt
echo "Solution Prefixes Found:" >> scan_summary.txt
cat /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/prefix_fuzz_values/fuzz1_value_YOUR_DOMAIN.txt >> scan_summary.txt
echo "" >> scan_summary.txt
echo "Bot URLs Discovered:" >> scan_summary.txt
cat /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/url_results/url_output_YOUR_DOMAIN.txt >> scan_summary.txt
echo "" >> scan_summary.txt
echo "Successful FFUF Hits:" >> scan_summary.txt
grep ",200," /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/ffuf_results/ffuf_results_YOUR_DOMAIN.csv >> scan_summary.txt
```

#### Exploitation Workflow

1. **Initial Analysis**: Review the JSON summary for high-level findings
2. **Deep Dive**: Examine FFUF CSV files for technical details
3. **URL Validation**: Test discovered URLs from `url_results/`
4. **Prefix Exploitation**: Use found prefixes for additional reconnaissance
5. **Documentation**: Combine findings into comprehensive reports

#### File Retention and Cleanup

```bash
# Archive results for later analysis
tar -czf copilot_scan_$(date +%Y%m%d).tar.gz /workspaces/power-pwn/src/powerpwn/copilot_studio/*_results/

# Clean up internal results (keep final results)
rm -rf /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/*

# Or selectively clean specific result types
rm /workspaces/power-pwn/src/powerpwn/copilot_studio/internal_results/ffuf_results/*.csv
```

### Security and Ethical Considerations

⚠️ Only scan systems you own or have permission to test.