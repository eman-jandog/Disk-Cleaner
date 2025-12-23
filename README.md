# Disk Cleaner Powershell Script
A powershell script to automate bulk storage formatting and partitioning.

# Reminders before using the script
1. Check 'diskpart.conf' and try to adjust disk number. In my case I have only 1 drive in my laptop, so when I attached a external automatically it will be placed on disk 1. In your case, it might be different so check with 'DISK MANAGEMENT' - available in all Windows PC.
2. Try at your own risk. Make sure to test first in sample drives before using fully on operations. Test the diskpart.conf with the diskpart shell and adjust necessary configurations.

## How to execute script?
1. Make sure to run the script with the same explorer directory.
2. Use this command when encounter permission error "powershell.exe -ExecutionPolicy Bypass -File <script full directory>"

## Final Message
If you have doubt with the codes, you can try to paste it on Chatgpt, Copilot, etc. to check for malicious lines.
Thanks for reading this far. Enjoy!