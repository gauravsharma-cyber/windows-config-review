# windows-config-review
This repository provides a batch script to perform basic configuration audits on Windows endpoints. It collects data on installed software, user groups, account policies, and group policy settings, and exports the results to a structured CSV file. Useful for system administrators, security auditors, and compliance reviews.

# Windows Endpoint Configuration Audit

This project contains two scripts that work together to run a configuration audit on Windows endpoints in the background and save the results to a shared folder.

# 📁 Files

**masterscript_endpoint.vbs: **Visual Basic Script that silently executes the batch script.

**Endpointscript.bat: **The main batch script that performs the endpoint configuration review.

# ▶️ How to Use

Place both masterscript_endpoint.vbs and Endpointscript.bat in the same folder.

Double-click masterscript_endpoint.vbs to execute the audit silently in the background.

# 📂 Output

The batch script will save the output to a shared folder specified inside Endpointscript.bat.

To customize the output location:

Open Endpointscript.bat in a text editor.

Search for the following line:

\\192.168.1.37\c$\test

Replace the IP address and path with your desired network location (e.g., your own machine's IP or another shared drive).

Please check the output in csv file.

# ✅ Notes

Administrator privileges may be required depending on the operations defined in Endpointscript.bat.

Ensure the destination folder is accessible from the endpoint.

# 📝 License

This project is licensed under the MIT License. See the LICENSE file for details.ur IP or shared drive IP with path specified.
