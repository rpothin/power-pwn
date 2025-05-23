import pandas as pd
import sys
import os

# Check if the correct number of arguments is provided
if len(sys.argv) < 2:
    print("Usage: python xlsx_to_json.py <input_excel_file> [output_json_file]")
    sys.exit(1)

# Get the Excel file path from the command line argument
excel_file = sys.argv[1]

# Determine the output JSON file name
if len(sys.argv) > 2:
    json_file = sys.argv[2]
else:
    # Default output file name is the input file name with .json extension,
    # stored in the same directory as the input Excel file.
    input_file_directory = os.path.dirname(excel_file)
    # If excel_file is just a name (e.g., 'file.xlsx'), dirname will be empty.
    # In that case, the output file will be created in the current working directory
    # where the script is run.
    if not input_file_directory:
        input_file_directory = "." 
    
    base_name = os.path.splitext(os.path.basename(excel_file))[0]
    json_file = os.path.join(input_file_directory, f"{base_name}.json")

# Read the Excel file
# If your Excel file has multiple sheets, you can specify the sheet name or index
# e.g., df = pd.read_excel(excel_file, sheet_name='Sheet1')
try:
    df = pd.read_excel(excel_file)
except FileNotFoundError:
    print(f"Error: Input file not found at {excel_file}")
    sys.exit(1)

# Convert the DataFrame to JSON
# The 'orient' parameter dictates the structure of the JSON.
# 'records' is a common choice, creating a list of records (dicts).
# Other options include 'split', 'index', 'columns', 'values', 'table'.
df.to_json(json_file, orient='records', indent=4)

print(f"Successfully converted '{excel_file}' to '{json_file}'")
