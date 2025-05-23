# Modules: Copilot Studio Hunter ‐ Enum

## Description
Utilizes open-source intelligence to compile lists of environment and tenant IDs from the Power Platform API subdomains to be used by the other Copilot Studio scanning sub-modules. Uses amass.

## Additional Installation Notes
1. Requires [amass](https://github.com/owasp-amass/amass) to be installed and to exist within the path as a prerequisite. Please see the attached link for the installations.

## Usage
### powerpwn cli
* Run the following command to enumerate new tenant/envrironment IDs:<br>
`copilot-studio-hunter enum -e {tenant|environment} -t {timeout in seconds}`

#### Command Parameters
* **enumerate**: Run the enumeration sub-module to either environment IDs or tenant IDs
* **timeout**: The timeout for the enumeration process to have (in seconds)