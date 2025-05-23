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

| Parameter        | Recommended Values | Description                                |
|------------------|--------------------|--------------------------------------------|
| threads          | 5-20               | Concurrency level                          |
| rate             | 10-100             | Requests per second                        |
| mode             | verbose or silent  | Verbosity level                            |
| timeout_prefix   | 300-600            | Prefix scan timeout (seconds)              |
| timeout_bots     | 300-900            | Bot scan timeout (seconds)                 |

### Output exploitation

Once the `deep-scan` module completes, it generates an XLSX file (e.g., `YOUR_DOMAIN_OR_TENANT_ID_YYYY_MM_DD.xlsx`) in the `src/powerpwn/copilot_studio/final_results/` directory.

To convert this XLSX file to a JSON format for easier programmatic access or integration with other tools, you can use the provided `xlsx_to_json.py` script.

1.  **Ensure Python and Pandas are installed:**
    If you haven't already, you might need to install pandas and its dependency for reading Excel files:
    ```bash
    pip install pandas openpyxl
    ```
    This step is also covered in the `check_prereqs.sh` script.

2.  **Run the conversion script:**
    Execute the script, providing the path to your input XLSX file. The JSON output will be saved in the same directory as the input file.
    ```bash
    python /workspaces/power-pwn/xlsx_to_json.py /workspaces/power-pwn/src/powerpwn/copilot_studio/final_results/YOUR_DOMAIN_OR_TENANT_ID_YYYY_MM_DD.xlsx
    ```
    Replace `YOUR_DOMAIN_OR_TENANT_ID_YYYY_MM_DD.xlsx` with the actual name of your generated Excel file.

    For example:
    ```bash
    python /workspaces/power-pwn/xlsx_to_json.py /workspaces/power-pwn/src/powerpwn/copilot_studio/final_results/rpothinmvp.onmicrosoft.com_2025_05_23.xlsx
    ```
    This will create a `rpothinmvp.onmicrosoft.com_2025_05_23.json` file in the `/workspaces/power-pwn/src/powerpwn/copilot_studio/final_results/` directory.

    You can also optionally specify a different output path for the JSON file:
    ```bash
    python /workspaces/power-pwn/xlsx_to_json.py /path/to/your/input.xlsx /path/to/your/output.json
    ```

### Security and Ethical Considerations

⚠️ Only scan systems you own or have permission to test.