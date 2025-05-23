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
        echo "  To install Google Chrome on Debian/Ubuntu, the system needs Google's repository."
        read -p "Attempt to add Google's repository and install Google Chrome now (requires sudo)? (y/N): " -n 1 -r REPLY; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Preparing to install Google Chrome..."
            # Ensure prerequisites for adding repo are installed
            sudo apt-get update && sudo apt-get install -y wget gpg software-properties-common
            
            echo "Adding Google Chrome repository..."
            # Add Google's signing key
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
            # Add Google Chrome repository
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
            
            echo "Updating package lists after adding Google Chrome repository..."
            if sudo apt-get update; then
                echo "Installing Google Chrome..."
                if sudo apt-get install -y google-chrome-stable; then
                    if command -v google-chrome &> /dev/null; then 
                        echo "✓ Google Chrome installed successfully."
                    else 
                        echo "✗ Google Chrome installation command ran, but 'google-chrome' is still not found. Check for errors."
                    fi
                else 
                    echo "✗ Google Chrome installation failed after adding repository. Please try manually."
                fi
            else
                echo "✗ Failed to update package lists after adding Google repository. Please check your APT configuration."
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

# Call the function to perform the checks
check_prerequisites
