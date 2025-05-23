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
`copilot-studio-hunter deep-scan -d {domain} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a tenant ID:<br>
`copilot-studio-hunter deep-scan -i {tenant ID} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

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

# Set target domain
TARGET_DOMAIN="contoso.com"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

echo "Target Domain: $TARGET_DOMAIN"
echo "FFUF Threads: $FFUF_THREADS"
echo "FFUF Rate: $FFUF_RATE requests/sec"
echo "Mode: $FFUF_MODE"

echo "Proceed? (y/N): " && read -r REPLY
[[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Cancelled."; exit 1; }

copilot-studio-hunter deep-scan \
    -d "$TARGET_DOMAIN" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Bash Example with Tenant ID Variable
```bash
#!/bin/bash

# Set target tenant ID
TARGET_TENANT_ID="12345678-1234-1234-1234-123456789abc"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

copilot-studio-hunter deep-scan \
    -i "$TARGET_TENANT_ID" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Parameter Value Guidelines

| Parameter        | Recommended Values | Description                                |
|------------------|--------------------|--------------------------------------------|
| threads          | 5-20               | Concurrency level                          |
| rate             | 10-100             | Requests per second                        |
| mode             | verbose or silent  | Verbosity level                            |
| timeout_prefix   | 300-600            | Prefix scan timeout (seconds)              |
| timeout_bots     | 300-900            | Bot scan timeout (seconds)                 |

### Security and Ethical Considerations

⚠️ Only scan systems you own or have permission to test.

### Complete Prerequisites Check

A script `check_prereqs.sh` has been created in the root of the `power-pwn` project to help you validate and install the necessary prerequisites.

To use it:
1.  Navigate to the root of the `power-pwn` project in your terminal.
2.  Make the script executable (this only needs to be done once):
    ```bash
    chmod +x check_prereqs.sh
    ```
3.  Run the script:
    ```bash
    ./check_prereqs.sh
    ```
The script will guide you through checking each prerequisite and offer to install them if they are missing.

Alternatively, you can still use the individual check snippets below to manually verify each component.

```bash
#!/bin/bash
echo "=== PowerPwn Copilot Studio Hunter - Prerequisites Check ==="

check_prerequisites() {
    local all_good_overall=true

    # Check FFUF
    if command -v ffuf &> /dev/null; then
        echo "✓ FFUF is installed"
    else
        echo "✗ FFUF not found."
        echo "  To install FFUF, the typical command is: go install github.com/ffuf/ffuf@latest"
        read -p "Attempt to install FFUF now? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing FFUF..."
            if go install github.com/ffuf/ffuf@latest; then
                if command -v ffuf &> /dev/null; then 
                    echo "✓ FFUF installed successfully."
                else 
                    echo "✗ FFUF installation command ran, but ffuf is still not found in PATH. Check your Go environment (GOPATH/bin)."
                    all_good_overall=false
                fi
            else 
                echo "✗ FFUF installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping FFUF installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Check Node.js & NPM
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        echo "✓ Node.js and NPM are installed"
    else
        echo "✗ Node.js and/or NPM not found."
        echo "  For Debian/Ubuntu, to install Node.js (which includes NPM), the command is: sudo apt-get update && sudo apt-get install -y nodejs npm"
        read -p "Attempt to install Node.js and NPM now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Node.js and NPM..."
            if sudo apt-get update && sudo apt-get install -y nodejs npm; then
                if command -v node &> /dev/null && command -v npm &> /dev/null; then 
                    echo "✓ Node.js and NPM installed successfully."
                else 
                    echo "✗ Node.js/NPM installation command ran, but they are still not found. Check for errors."
                    all_good_overall=false
                fi
            else 
                echo "✗ Node.js/NPM installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping Node.js/NPM installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Puppeteer (dependencies)
    # This path is relative to the project root. Ensure the script is run from there.
    PUPPETEER_DIR_REL="src/powerpwn/copilot_studio/tools/pup_is_webchat_live"

    if [ -d "$PUPPETEER_DIR_REL" ]; then
        if [ -f "$PUPPETEER_DIR_REL/package.json" ]; then
            echo "✓ Puppeteer project directory and package.json found ($PUPPETEER_DIR_REL)"
            # Check for a key puppeteer file in node_modules as an indicator of installation
            if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then
                echo "✓ Puppeteer dependencies appear to be installed in $PUPPETEER_DIR_REL."
            else
                echo "✗ Puppeteer dependencies (specifically 'puppeteer' in node_modules) not found in $PUPPETEER_DIR_REL."
                echo "  To install, the command is: (cd \"$PUPPETEER_DIR_REL\" && npm install)"
                read -p "Attempt to install Puppeteer dependencies now? (y/N): " -n 1 -r REPLY; echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Installing Puppeteer dependencies in $PUPPETEER_DIR_REL..."
                    if (cd "$PUPPETEER_DIR_REL" && npm install); then
                        if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then 
                            echo "✓ Puppeteer dependencies installed successfully."
                        else 
                            echo "✗ Puppeteer dependencies installation command ran, but 'puppeteer' module still not found. Check for errors in $PUPPETEER_DIR_REL."
                            all_good_overall=false
                        fi
                    else 
                        echo "✗ Puppeteer dependencies installation failed. Please try manually in $PUPPETEER_DIR_REL."
                        all_good_overall=false
                    fi
                else 
                    echo "Skipping Puppeteer dependencies installation. Please install manually."
                    all_good_overall=false
                fi
            fi
        else
            echo "✗ Puppeteer package.json not found in $PUPPETEER_DIR_REL. Cannot install dependencies."
            all_good_overall=false
        fi
    else
        echo "✗ Puppeteer project directory not found at: $PUPPETEER_DIR_REL (expected relative to current directory: $PWD)."
        echo "  Please ensure the project is cloned correctly and you are running this script from the project root."
        all_good_overall=false
    fi
    echo "---"

    # Check Chrome (optional)
    if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then
        echo "✓ Google Chrome or Chromium is installed (Optional but recommended)"
    else
        echo "! Optional: Chrome/Chromium not found. Puppeteer may download its own instance if a system one isn't found."
        echo "  For a system-wide installation on Debian/Ubuntu, the command is: sudo apt-get update && sudo apt-get install -y google-chrome-stable"
        read -p "Attempt to install Google Chrome now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Google Chrome..."
            if sudo apt-get update && sudo apt-get install -y google-chrome-stable; then
                if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then 
                    echo "✓ Google Chrome/Chromium installed successfully."
                else 
                    echo "✗ Chrome installation command ran, but it's still not found. Check for errors."
                fi
            else 
                echo "✗ Chrome installation failed. Please try manually."
            fi
        else 
            echo "Skipping Google Chrome installation."
        fi
    fi

    echo "-----------------------------------------------------"
    if [ "$all_good_overall" = true ]; then
        echo "✓ All critical prerequisites are met or their installation was successful/skipped as per user choice (for optional items)."
        echo "  If you skipped a critical installation, the main tool may not function."
        return 0
    else
        echo "✗ Some critical prerequisites are missing, or their installation was skipped/failed."
        echo "  Please review the messages above and ensure all necessary components are correctly installed for the tool to function."
        return 1
    fi
}

# To run this check, save the content of this entire bash script block (starting with #!/bin/bash) 
# into a file (e.g., check_prereqs.sh) in the root of the power-pwn project.
# Then, give it execute permissions (chmod +x check_prereqs.sh) and run it (./check_prereqs.sh).
#
# Alternatively, you can copy and paste the check_prerequisites function definition 
# and then call it directly in your terminal (ensure you are in the project root):
# check_prerequisites

# Example of calling the function if the script is executed directly:
check_prerequisites
```

## Usage
### powerpwn cli
* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a domain:<br>
`copilot-studio-hunter deep-scan -d {domain} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a tenant ID:<br>
`copilot-studio-hunter deep-scan -i {tenant ID} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

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

# Set target domain
TARGET_DOMAIN="contoso.com"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

echo "Target Domain: $TARGET_DOMAIN"
echo "FFUF Threads: $FFUF_THREADS"
echo "FFUF Rate: $FFUF_RATE requests/sec"
echo "Mode: $FFUF_MODE"

echo "Proceed? (y/N): " && read -r REPLY
[[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Cancelled."; exit 1; }

copilot-studio-hunter deep-scan \
    -d "$TARGET_DOMAIN" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Bash Example with Tenant ID Variable
```bash
#!/bin/bash

# Set target tenant ID
TARGET_TENANT_ID="12345678-1234-1234-1234-123456789abc"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

copilot-studio-hunter deep-scan \
    -i "$TARGET_TENANT_ID" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Parameter Value Guidelines

| Parameter        | Recommended Values | Description                                |
|------------------|--------------------|--------------------------------------------|
| threads          | 5-20               | Concurrency level                          |
| rate             | 10-100             | Requests per second                        |
| mode             | verbose or silent  | Verbosity level                            |
| timeout_prefix   | 300-600            | Prefix scan timeout (seconds)              |
| timeout_bots     | 300-900            | Bot scan timeout (seconds)                 |

### Security and Ethical Considerations

⚠️ Only scan systems you own or have permission to test.

### Complete Prerequisites Check

A script `check_prereqs.sh` has been created in the root of the `power-pwn` project to help you validate and install the necessary prerequisites.

To use it:
1.  Navigate to the root of the `power-pwn` project in your terminal.
2.  Make the script executable (this only needs to be done once):
    ```bash
    chmod +x check_prereqs.sh
    ```
3.  Run the script:
    ```bash
    ./check_prereqs.sh
    ```
The script will guide you through checking each prerequisite and offer to install them if they are missing.

Alternatively, you can still use the individual check snippets below to manually verify each component.

```bash
#!/bin/bash
echo "=== PowerPwn Copilot Studio Hunter - Prerequisites Check ==="

check_prerequisites() {
    local all_good_overall=true

    # Check FFUF
    if command -v ffuf &> /dev/null; then
        echo "✓ FFUF is installed"
    else
        echo "✗ FFUF not found."
        echo "  To install FFUF, the typical command is: go install github.com/ffuf/ffuf@latest"
        read -p "Attempt to install FFUF now? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing FFUF..."
            if go install github.com/ffuf/ffuf@latest; then
                if command -v ffuf &> /dev/null; then 
                    echo "✓ FFUF installed successfully."
                else 
                    echo "✗ FFUF installation command ran, but ffuf is still not found in PATH. Check your Go environment (GOPATH/bin)."
                    all_good_overall=false
                fi
            else 
                echo "✗ FFUF installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping FFUF installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Check Node.js & NPM
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        echo "✓ Node.js and NPM are installed"
    else
        echo "✗ Node.js and/or NPM not found."
        echo "  For Debian/Ubuntu, to install Node.js (which includes NPM), the command is: sudo apt-get update && sudo apt-get install -y nodejs npm"
        read -p "Attempt to install Node.js and NPM now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Node.js and NPM..."
            if sudo apt-get update && sudo apt-get install -y nodejs npm; then
                if command -v node &> /dev/null && command -v npm &> /dev/null; then 
                    echo "✓ Node.js and NPM installed successfully."
                else 
                    echo "✗ Node.js/NPM installation command ran, but they are still not found. Check for errors."
                    all_good_overall=false
                fi
            else 
                echo "✗ Node.js/NPM installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping Node.js/NPM installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Puppeteer (dependencies)
    # This path is relative to the project root. Ensure the script is run from there.
    PUPPETEER_DIR_REL="src/powerpwn/copilot_studio/tools/pup_is_webchat_live"

    if [ -d "$PUPPETEER_DIR_REL" ]; then
        if [ -f "$PUPPETEER_DIR_REL/package.json" ]; then
            echo "✓ Puppeteer project directory and package.json found ($PUPPETEER_DIR_REL)"
            # Check for a key puppeteer file in node_modules as an indicator of installation
            if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then
                echo "✓ Puppeteer dependencies appear to be installed in $PUPPETEER_DIR_REL."
            else
                echo "✗ Puppeteer dependencies (specifically 'puppeteer' in node_modules) not found in $PUPPETEER_DIR_REL."
                echo "  To install, the command is: (cd \"$PUPPETEER_DIR_REL\" && npm install)"
                read -p "Attempt to install Puppeteer dependencies now? (y/N): " -n 1 -r REPLY; echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Installing Puppeteer dependencies in $PUPPETEER_DIR_REL..."
                    if (cd "$PUPPETEER_DIR_REL" && npm install); then
                        if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then 
                            echo "✓ Puppeteer dependencies installed successfully."
                        else 
                            echo "✗ Puppeteer dependencies installation command ran, but 'puppeteer' module still not found. Check for errors in $PUPPETEER_DIR_REL."
                            all_good_overall=false
                        fi
                    else 
                        echo "✗ Puppeteer dependencies installation failed. Please try manually in $PUPPETEER_DIR_REL."
                        all_good_overall=false
                    fi
                else 
                    echo "Skipping Puppeteer dependencies installation. Please install manually."
                    all_good_overall=false
                fi
            fi
        else
            echo "✗ Puppeteer package.json not found in $PUPPETEER_DIR_REL. Cannot install dependencies."
            all_good_overall=false
        fi
    else
        echo "✗ Puppeteer project directory not found at: $PUPPETEER_DIR_REL (expected relative to current directory: $PWD)."
        echo "  Please ensure the project is cloned correctly and you are running this script from the project root."
        all_good_overall=false
    fi
    echo "---"

    # Check Chrome (optional)
    if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then
        echo "✓ Google Chrome or Chromium is installed (Optional but recommended)"
    else
        echo "! Optional: Chrome/Chromium not found. Puppeteer may download its own instance if a system one isn't found."
        echo "  For a system-wide installation on Debian/Ubuntu, the command is: sudo apt-get update && sudo apt-get install -y google-chrome-stable"
        read -p "Attempt to install Google Chrome now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Google Chrome..."
            if sudo apt-get update && sudo apt-get install -y google-chrome-stable; then
                if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then 
                    echo "✓ Google Chrome/Chromium installed successfully."
                else 
                    echo "✗ Chrome installation command ran, but it's still not found. Check for errors."
                fi
            else 
                echo "✗ Chrome installation failed. Please try manually."
            fi
        else 
            echo "Skipping Google Chrome installation."
        fi
    fi

    echo "-----------------------------------------------------"
    if [ "$all_good_overall" = true ]; then
        echo "✓ All critical prerequisites are met or their installation was successful/skipped as per user choice (for optional items)."
        echo "  If you skipped a critical installation, the main tool may not function."
        return 0
    else
        echo "✗ Some critical prerequisites are missing, or their installation was skipped/failed."
        echo "  Please review the messages above and ensure all necessary components are correctly installed for the tool to function."
        return 1
    fi
}

# To run this check, save the content of this entire bash script block (starting with #!/bin/bash) 
# into a file (e.g., check_prereqs.sh) in the root of the power-pwn project.
# Then, give it execute permissions (chmod +x check_prereqs.sh) and run it (./check_prereqs.sh).
#
# Alternatively, you can copy and paste the check_prerequisites function definition 
# and then call it directly in your terminal (ensure you are in the project root):
# check_prerequisites

# Example of calling the function if the script is executed directly:
check_prerequisites
```

## Usage
### powerpwn cli
* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a domain:<br>
`copilot-studio-hunter deep-scan -d {domain} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a tenant ID:<br>
`copilot-studio-hunter deep-scan -i {tenant ID} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

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

# Set target domain
TARGET_DOMAIN="contoso.com"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

echo "Target Domain: $TARGET_DOMAIN"
echo "FFUF Threads: $FFUF_THREADS"
echo "FFUF Rate: $FFUF_RATE requests/sec"
echo "Mode: $FFUF_MODE"

echo "Proceed? (y/N): " && read -r REPLY
[[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Cancelled."; exit 1; }

copilot-studio-hunter deep-scan \
    -d "$TARGET_DOMAIN" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Bash Example with Tenant ID Variable
```bash
#!/bin/bash

# Set target tenant ID
TARGET_TENANT_ID="12345678-1234-1234-1234-123456789abc"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

copilot-studio-hunter deep-scan \
    -i "$TARGET_TENANT_ID" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Parameter Value Guidelines

| Parameter        | Recommended Values | Description                                |
|------------------|--------------------|--------------------------------------------|
| threads          | 5-20               | Concurrency level                          |
| rate             | 10-100             | Requests per second                        |
| mode             | verbose or silent  | Verbosity level                            |
| timeout_prefix   | 300-600            | Prefix scan timeout (seconds)              |
| timeout_bots     | 300-900            | Bot scan timeout (seconds)                 |

### Security and Ethical Considerations

⚠️ Only scan systems you own or have permission to test.

### Complete Prerequisites Check

A script `check_prereqs.sh` has been created in the root of the `power-pwn` project to help you validate and install the necessary prerequisites.

To use it:
1.  Navigate to the root of the `power-pwn` project in your terminal.
2.  Make the script executable (this only needs to be done once):
    ```bash
    chmod +x check_prereqs.sh
    ```
3.  Run the script:
    ```bash
    ./check_prereqs.sh
    ```
The script will guide you through checking each prerequisite and offer to install them if they are missing.

Alternatively, you can still use the individual check snippets below to manually verify each component.

```bash
#!/bin/bash
echo "=== PowerPwn Copilot Studio Hunter - Prerequisites Check ==="

check_prerequisites() {
    local all_good_overall=true

    # Check FFUF
    if command -v ffuf &> /dev/null; then
        echo "✓ FFUF is installed"
    else
        echo "✗ FFUF not found."
        echo "  To install FFUF, the typical command is: go install github.com/ffuf/ffuf@latest"
        read -p "Attempt to install FFUF now? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing FFUF..."
            if go install github.com/ffuf/ffuf@latest; then
                if command -v ffuf &> /dev/null; then 
                    echo "✓ FFUF installed successfully."
                else 
                    echo "✗ FFUF installation command ran, but ffuf is still not found in PATH. Check your Go environment (GOPATH/bin)."
                    all_good_overall=false
                fi
            else 
                echo "✗ FFUF installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping FFUF installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Check Node.js & NPM
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        echo "✓ Node.js and NPM are installed"
    else
        echo "✗ Node.js and/or NPM not found."
        echo "  For Debian/Ubuntu, to install Node.js (which includes NPM), the command is: sudo apt-get update && sudo apt-get install -y nodejs npm"
        read -p "Attempt to install Node.js and NPM now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Node.js and NPM..."
            if sudo apt-get update && sudo apt-get install -y nodejs npm; then
                if command -v node &> /dev/null && command -v npm &> /dev/null; then 
                    echo "✓ Node.js and NPM installed successfully."
                else 
                    echo "✗ Node.js/NPM installation command ran, but they are still not found. Check for errors."
                    all_good_overall=false
                fi
            else 
                echo "✗ Node.js/NPM installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping Node.js/NPM installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Puppeteer (dependencies)
    # This path is relative to the project root. Ensure the script is run from there.
    PUPPETEER_DIR_REL="src/powerpwn/copilot_studio/tools/pup_is_webchat_live"

    if [ -d "$PUPPETEER_DIR_REL" ]; then
        if [ -f "$PUPPETEER_DIR_REL/package.json" ]; then
            echo "✓ Puppeteer project directory and package.json found ($PUPPETEER_DIR_REL)"
            # Check for a key puppeteer file in node_modules as an indicator of installation
            if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then
                echo "✓ Puppeteer dependencies appear to be installed in $PUPPETEER_DIR_REL."
            else
                echo "✗ Puppeteer dependencies (specifically 'puppeteer' in node_modules) not found in $PUPPETEER_DIR_REL."
                echo "  To install, the command is: (cd \"$PUPPETEER_DIR_REL\" && npm install)"
                read -p "Attempt to install Puppeteer dependencies now? (y/N): " -n 1 -r REPLY; echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Installing Puppeteer dependencies in $PUPPETEER_DIR_REL..."
                    if (cd "$PUPPETEER_DIR_REL" && npm install); then
                        if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then 
                            echo "✓ Puppeteer dependencies installed successfully."
                        else 
                            echo "✗ Puppeteer dependencies installation command ran, but 'puppeteer' module still not found. Check for errors in $PUPPETEER_DIR_REL."
                            all_good_overall=false
                        fi
                    else 
                        echo "✗ Puppeteer dependencies installation failed. Please try manually in $PUPPETEER_DIR_REL."
                        all_good_overall=false
                    fi
                else 
                    echo "Skipping Puppeteer dependencies installation. Please install manually."
                    all_good_overall=false
                fi
            fi
        else
            echo "✗ Puppeteer package.json not found in $PUPPETEER_DIR_REL. Cannot install dependencies."
            all_good_overall=false
        fi
    else
        echo "✗ Puppeteer project directory not found at: $PUPPETEER_DIR_REL (expected relative to current directory: $PWD)."
        echo "  Please ensure the project is cloned correctly and you are running this script from the project root."
        all_good_overall=false
    fi
    echo "---"

    # Check Chrome (optional)
    if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then
        echo "✓ Google Chrome or Chromium is installed (Optional but recommended)"
    else
        echo "! Optional: Chrome/Chromium not found. Puppeteer may download its own instance if a system one isn't found."
        echo "  For a system-wide installation on Debian/Ubuntu, the command is: sudo apt-get update && sudo apt-get install -y google-chrome-stable"
        read -p "Attempt to install Google Chrome now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Google Chrome..."
            if sudo apt-get update && sudo apt-get install -y google-chrome-stable; then
                if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then 
                    echo "✓ Google Chrome/Chromium installed successfully."
                else 
                    echo "✗ Chrome installation command ran, but it's still not found. Check for errors."
                fi
            else 
                echo "✗ Chrome installation failed. Please try manually."
            fi
        else 
            echo "Skipping Google Chrome installation."
        fi
    fi

    echo "-----------------------------------------------------"
    if [ "$all_good_overall" = true ]; then
        echo "✓ All critical prerequisites are met or their installation was successful/skipped as per user choice (for optional items)."
        echo "  If you skipped a critical installation, the main tool may not function."
        return 0
    else
        echo "✗ Some critical prerequisites are missing, or their installation was skipped/failed."
        echo "  Please review the messages above and ensure all necessary components are correctly installed for the tool to function."
        return 1
    fi
}

# To run this check, save the content of this entire bash script block (starting with #!/bin/bash) 
# into a file (e.g., check_prereqs.sh) in the root of the power-pwn project.
# Then, give it execute permissions (chmod +x check_prereqs.sh) and run it (./check_prereqs.sh).
#
# Alternatively, you can copy and paste the check_prerequisites function definition 
# and then call it directly in your terminal (ensure you are in the project root):
# check_prerequisites

# Example of calling the function if the script is executed directly:
check_prerequisites
```

## Usage
### powerpwn cli
* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a domain:<br>
`copilot-studio-hunter deep-scan -d {domain} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a tenant ID:<br>
`copilot-studio-hunter deep-scan -i {tenant ID} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

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

# Set target domain
TARGET_DOMAIN="contoso.com"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

echo "Target Domain: $TARGET_DOMAIN"
echo "FFUF Threads: $FFUF_THREADS"
echo "FFUF Rate: $FFUF_RATE requests/sec"
echo "Mode: $FFUF_MODE"

echo "Proceed? (y/N): " && read -r REPLY
[[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Cancelled."; exit 1; }

copilot-studio-hunter deep-scan \
    -d "$TARGET_DOMAIN" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Bash Example with Tenant ID Variable
```bash
#!/bin/bash

# Set target tenant ID
TARGET_TENANT_ID="12345678-1234-1234-1234-123456789abc"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

copilot-studio-hunter deep-scan \
    -i "$TARGET_TENANT_ID" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Parameter Value Guidelines

| Parameter        | Recommended Values | Description                                |
|------------------|--------------------|--------------------------------------------|
| threads          | 5-20               | Concurrency level                          |
| rate             | 10-100             | Requests per second                        |
| mode             | verbose or silent  | Verbosity level                            |
| timeout_prefix   | 300-600            | Prefix scan timeout (seconds)              |
| timeout_bots     | 300-900            | Bot scan timeout (seconds)                 |

### Security and Ethical Considerations

⚠️ Only scan systems you own or have permission to test.

### Complete Prerequisites Check

A script `check_prereqs.sh` has been created in the root of the `power-pwn` project to help you validate and install the necessary prerequisites.

To use it:
1.  Navigate to the root of the `power-pwn` project in your terminal.
2.  Make the script executable (this only needs to be done once):
    ```bash
    chmod +x check_prereqs.sh
    ```
3.  Run the script:
    ```bash
    ./check_prereqs.sh
    ```
The script will guide you through checking each prerequisite and offer to install them if they are missing.

Alternatively, you can still use the individual check snippets below to manually verify each component.

```bash
#!/bin/bash
echo "=== PowerPwn Copilot Studio Hunter - Prerequisites Check ==="

check_prerequisites() {
    local all_good_overall=true

    # Check FFUF
    if command -v ffuf &> /dev/null; then
        echo "✓ FFUF is installed"
    else
        echo "✗ FFUF not found."
        echo "  To install FFUF, the typical command is: go install github.com/ffuf/ffuf@latest"
        read -p "Attempt to install FFUF now? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing FFUF..."
            if go install github.com/ffuf/ffuf@latest; then
                if command -v ffuf &> /dev/null; then 
                    echo "✓ FFUF installed successfully."
                else 
                    echo "✗ FFUF installation command ran, but ffuf is still not found in PATH. Check your Go environment (GOPATH/bin)."
                    all_good_overall=false
                fi
            else 
                echo "✗ FFUF installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping FFUF installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Check Node.js & NPM
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        echo "✓ Node.js and NPM are installed"
    else
        echo "✗ Node.js and/or NPM not found."
        echo "  For Debian/Ubuntu, to install Node.js (which includes NPM), the command is: sudo apt-get update && sudo apt-get install -y nodejs npm"
        read -p "Attempt to install Node.js and NPM now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Node.js and NPM..."
            if sudo apt-get update && sudo apt-get install -y nodejs npm; then
                if command -v node &> /dev/null && command -v npm &> /dev/null; then 
                    echo "✓ Node.js and NPM installed successfully."
                else 
                    echo "✗ Node.js/NPM installation command ran, but they are still not found. Check for errors."
                    all_good_overall=false
                fi
            else 
                echo "✗ Node.js/NPM installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping Node.js/NPM installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Puppeteer (dependencies)
    # This path is relative to the project root. Ensure the script is run from there.
    PUPPETEER_DIR_REL="src/powerpwn/copilot_studio/tools/pup_is_webchat_live"

    if [ -d "$PUPPETEER_DIR_REL" ]; then
        if [ -f "$PUPPETEER_DIR_REL/package.json" ]; then
            echo "✓ Puppeteer project directory and package.json found ($PUPPETEER_DIR_REL)"
            # Check for a key puppeteer file in node_modules as an indicator of installation
            if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then
                echo "✓ Puppeteer dependencies appear to be installed in $PUPPETEER_DIR_REL."
            else
                echo "✗ Puppeteer dependencies (specifically 'puppeteer' in node_modules) not found in $PUPPETEER_DIR_REL."
                echo "  To install, the command is: (cd \"$PUPPETEER_DIR_REL\" && npm install)"
                read -p "Attempt to install Puppeteer dependencies now? (y/N): " -n 1 -r REPLY; echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Installing Puppeteer dependencies in $PUPPETEER_DIR_REL..."
                    if (cd "$PUPPETEER_DIR_REL" && npm install); then
                        if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then 
                            echo "✓ Puppeteer dependencies installed successfully."
                        else 
                            echo "✗ Puppeteer dependencies installation command ran, but 'puppeteer' module still not found. Check for errors in $PUPPETEER_DIR_REL."
                            all_good_overall=false
                        fi
                    else 
                        echo "✗ Puppeteer dependencies installation failed. Please try manually in $PUPPETEER_DIR_REL."
                        all_good_overall=false
                    fi
                else 
                    echo "Skipping Puppeteer dependencies installation. Please install manually."
                    all_good_overall=false
                fi
            fi
        else
            echo "✗ Puppeteer package.json not found in $PUPPETEER_DIR_REL. Cannot install dependencies."
            all_good_overall=false
        fi
    else
        echo "✗ Puppeteer project directory not found at: $PUPPETEER_DIR_REL (expected relative to current directory: $PWD)."
        echo "  Please ensure the project is cloned correctly and you are running this script from the project root."
        all_good_overall=false
    fi
    echo "---"

    # Check Chrome (optional)
    if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then
        echo "✓ Google Chrome or Chromium is installed (Optional but recommended)"
    else
        echo "! Optional: Chrome/Chromium not found. Puppeteer may download its own instance if a system one isn't found."
        echo "  For a system-wide installation on Debian/Ubuntu, the command is: sudo apt-get update && sudo apt-get install -y google-chrome-stable"
        read -p "Attempt to install Google Chrome now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Google Chrome..."
            if sudo apt-get update && sudo apt-get install -y google-chrome-stable; then
                if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then 
                    echo "✓ Google Chrome/Chromium installed successfully."
                else 
                    echo "✗ Chrome installation command ran, but it's still not found. Check for errors."
                fi
            else 
                echo "✗ Chrome installation failed. Please try manually."
            fi
        else 
            echo "Skipping Google Chrome installation."
        fi
    fi

    echo "-----------------------------------------------------"
    if [ "$all_good_overall" = true ]; then
        echo "✓ All critical prerequisites are met or their installation was successful/skipped as per user choice (for optional items)."
        echo "  If you skipped a critical installation, the main tool may not function."
        return 0
    else
        echo "✗ Some critical prerequisites are missing, or their installation was skipped/failed."
        echo "  Please review the messages above and ensure all necessary components are correctly installed for the tool to function."
        return 1
    fi
}

# To run this check, save the content of this entire bash script block (starting with #!/bin/bash) 
# into a file (e.g., check_prereqs.sh) in the root of the power-pwn project.
# Then, give it execute permissions (chmod +x check_prereqs.sh) and run it (./check_prereqs.sh).
#
# Alternatively, you can copy and paste the check_prerequisites function definition 
# and then call it directly in your terminal (ensure you are in the project root):
# check_prerequisites

# Example of calling the function if the script is executed directly:
check_prerequisites
```

## Usage
### powerpwn cli
* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a domain:<br>
`copilot-studio-hunter deep-scan -d {domain} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

* Run the following command to perform a deep scan of accessible Copilot Studio demo websites based on a tenant ID:<br>
`copilot-studio-hunter deep-scan -i {tenant ID} -t {no. of FFUF threads} -r {no. of FFUF requests per second} -mode {verbose or silent mode to be used in FFUF} -tp {environment solution prefix scan timeout in seconds} -tb {bots scan timeout in seconds}`

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

# Set target domain
TARGET_DOMAIN="contoso.com"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

echo "Target Domain: $TARGET_DOMAIN"
echo "FFUF Threads: $FFUF_THREADS"
echo "FFUF Rate: $FFUF_RATE requests/sec"
echo "Mode: $FFUF_MODE"

echo "Proceed? (y/N): " && read -r REPLY
[[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Cancelled."; exit 1; }

copilot-studio-hunter deep-scan \
    -d "$TARGET_DOMAIN" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Bash Example with Tenant ID Variable
```bash
#!/bin/bash

# Set target tenant ID
TARGET_TENANT_ID="12345678-1234-1234-1234-123456789abc"

# Configuration
FFUF_THREADS=10
FFUF_RATE=50
FFUF_MODE="verbose"
TIMEOUT_PREFIX=300
TIMEOUT_BOTS=300

copilot-studio-hunter deep-scan \
    -i "$TARGET_TENANT_ID" \
    -t "$FFUF_THREADS" \
    -r "$FFUF_RATE" \
    -mode "$FFUF_MODE" \
    -tp "$TIMEOUT_PREFIX" \
    -tb "$TIMEOUT_BOTS"
```

### Parameter Value Guidelines

| Parameter        | Recommended Values | Description                                |
|------------------|--------------------|--------------------------------------------|
| threads          | 5-20               | Concurrency level                          |
| rate             | 10-100             | Requests per second                        |
| mode             | verbose or silent  | Verbosity level                            |
| timeout_prefix   | 300-600            | Prefix scan timeout (seconds)              |
| timeout_bots     | 300-900            | Bot scan timeout (seconds)                 |

### Security and Ethical Considerations

⚠️ Only scan systems you own or have permission to test.

### Complete Prerequisites Check

A script `check_prereqs.sh` has been created in the root of the `power-pwn` project to help you validate and install the necessary prerequisites.

To use it:
1.  Navigate to the root of the `power-pwn` project in your terminal.
2.  Make the script executable (this only needs to be done once):
    ```bash
    chmod +x check_prereqs.sh
    ```
3.  Run the script:
    ```bash
    ./check_prereqs.sh
    ```
The script will guide you through checking each prerequisite and offer to install them if they are missing.

Alternatively, you can still use the individual check snippets below to manually verify each component.

```bash
#!/bin/bash
echo "=== PowerPwn Copilot Studio Hunter - Prerequisites Check ==="

check_prerequisites() {
    local all_good_overall=true

    # Check FFUF
    if command -v ffuf &> /dev/null; then
        echo "✓ FFUF is installed"
    else
        echo "✗ FFUF not found."
        echo "  To install FFUF, the typical command is: go install github.com/ffuf/ffuf@latest"
        read -p "Attempt to install FFUF now? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing FFUF..."
            if go install github.com/ffuf/ffuf@latest; then
                if command -v ffuf &> /dev/null; then 
                    echo "✓ FFUF installed successfully."
                else 
                    echo "✗ FFUF installation command ran, but ffuf is still not found in PATH. Check your Go environment (GOPATH/bin)."
                    all_good_overall=false
                fi
            else 
                echo "✗ FFUF installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping FFUF installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Check Node.js & NPM
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        echo "✓ Node.js and NPM are installed"
    else
        echo "✗ Node.js and/or NPM not found."
        echo "  For Debian/Ubuntu, to install Node.js (which includes NPM), the command is: sudo apt-get update && sudo apt-get install -y nodejs npm"
        read -p "Attempt to install Node.js and NPM now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Node.js and NPM..."
            if sudo apt-get update && sudo apt-get install -y nodejs npm; then
                if command -v node &> /dev/null && command -v npm &> /dev/null; then 
                    echo "✓ Node.js and NPM installed successfully."
                else 
                    echo "✗ Node.js/NPM installation command ran, but they are still not found. Check for errors."
                    all_good_overall=false
                fi
            else 
                echo "✗ Node.js/NPM installation failed. Please try manually."
                all_good_overall=false
            fi
        else 
            echo "Skipping Node.js/NPM installation. Please install manually."
            all_good_overall=false
        fi
    fi
    echo "---"

    # Puppeteer (dependencies)
    # This path is relative to the project root. Ensure the script is run from there.
    PUPPETEER_DIR_REL="src/powerpwn/copilot_studio/tools/pup_is_webchat_live"

    if [ -d "$PUPPETEER_DIR_REL" ]; then
        if [ -f "$PUPPETEER_DIR_REL/package.json" ]; then
            echo "✓ Puppeteer project directory and package.json found ($PUPPETEER_DIR_REL)"
            # Check for a key puppeteer file in node_modules as an indicator of installation
            if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then
                echo "✓ Puppeteer dependencies appear to be installed in $PUPPETEER_DIR_REL."
            else
                echo "✗ Puppeteer dependencies (specifically 'puppeteer' in node_modules) not found in $PUPPETEER_DIR_REL."
                echo "  To install, the command is: (cd \"$PUPPETEER_DIR_REL\" && npm install)"
                read -p "Attempt to install Puppeteer dependencies now? (y/N): " -n 1 -r REPLY; echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Installing Puppeteer dependencies in $PUPPETEER_DIR_REL..."
                    if (cd "$PUPPETEER_DIR_REL" && npm install); then
                        if [ -f "$PUPPETEER_DIR_REL/node_modules/puppeteer/package.json" ]; then 
                            echo "✓ Puppeteer dependencies installed successfully."
                        else 
                            echo "✗ Puppeteer dependencies installation command ran, but 'puppeteer' module still not found. Check for errors in $PUPPETEER_DIR_REL."
                            all_good_overall=false
                        fi
                    else 
                        echo "✗ Puppeteer dependencies installation failed. Please try manually in $PUPPETEER_DIR_REL."
                        all_good_overall=false
                    fi
                else 
                    echo "Skipping Puppeteer dependencies installation. Please install manually."
                    all_good_overall=false
                fi
            fi
        else
            echo "✗ Puppeteer package.json not found in $PUPPETEER_DIR_REL. Cannot install dependencies."
            all_good_overall=false
        fi
    else
        echo "✗ Puppeteer project directory not found at: $PUPPETEER_DIR_REL (expected relative to current directory: $PWD)."
        echo "  Please ensure the project is cloned correctly and you are running this script from the project root."
        all_good_overall=false
    fi
    echo "---"

    # Check Chrome (optional)
    if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then
        echo "✓ Google Chrome or Chromium is installed (Optional but recommended)"
    else
        echo "! Optional: Chrome/Chromium not found. Puppeteer may download its own instance if a system one isn't found."
        echo "  For a system-wide installation on Debian/Ubuntu, the command is: sudo apt-get update && sudo apt-get install -y google-chrome-stable"
        read -p "Attempt to install Google Chrome now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Google Chrome..."
            if sudo apt-get update && sudo apt-get install -y google-chrome-stable; then
                if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then 
                    echo "✓ Google Chrome/Chromium installed successfully."
                else 
                    echo "✗ Chrome installation command ran, but it's still not found. Check for errors."
                fi
            else 
                echo "✗ Chrome installation failed. Please try manually."
            fi
        else 
            echo "Skipping Google Chrome installation."
        fi
    fi

    echo "-----------------------------------------------------"
    if [ "$all_good_overall" = true ]; then
        echo "✓ All critical prerequisites are met or their installation was successful/skipped as per user choice (for optional items)."
        echo "  If you skipped a critical installation, the main tool may not function."
        return 0
    else
        echo "✗ Some critical prerequisites are missing, or their installation was skipped/failed."
        echo "  Please review the messages above and ensure all necessary components are correctly installed for the tool to function."
        return 1
    fi
}

# To run this check, save the content of this entire bash script block (starting with #!/bin/bash) 
# into a file (e.g., check_prereqs.sh) in the root of the power-pwn project.
# Then, give it execute permissions (chmod +x check_prereqs.sh) and run it (./check_prereqs.sh).
#
# Alternatively, you can copy and paste the check_prerequisites function definition 
# and then call it directly in your terminal (ensure you are in the project root):
# check_prerequisites

# Example of calling the function if the script is executed directly:
check_prerequisites
```