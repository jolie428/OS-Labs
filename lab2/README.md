Lab 2: Simple Antivirus

Overview
This project watches a folder and moves malicious files to a quarantine folder. A second script lets the user review the quarantined files.

Folder contents
antivirusd.sh: the antivirus daemon
restore.sh: the restore tool
antivirus-cron.sh: the cron version (bonus)
Makefile: commands to run everything
README.md: this file
.gitignore: files git should ignore

Files created while running: test_dir, malicious_dir, directory-info.last, directory-info.new, whitelist.txt

What you need (Ubuntu)
Run these commands:
    sudo apt update
    sudo apt install make cron
    chmod +x antivirusd.sh restore.sh antivirus-cron.sh

How to run
1. Open a terminal in the lab2 folder.
2. Create a test folder with some files:
    mkdir -p test_dir
    echo "normal file" > test_dir/notes.txt
    echo "this has a trojan" > test_dir/report.txt
    echo "program" > test_dir/setup.exe
3. Start the antivirus:
    make
It creates malicious_dir if it does not exist and checks test_dir every 5 seconds. Press Ctrl+C to stop it.
4. Review quarantined files (do not run this while the antivirus is running):
    make restore
Type a file number, then 1 to restore it, 2 to delete it, or 3 to leave it. Type 0 to quit.

Flagged extensions and keywords
They are at the top of antivirusd.sh:
    Extensions="exe bat vbs scr ps1"
    Keywords="virus|trojan|malware|worm|ransomware"

Bonus: whitelist
When restore.sh restores a file (option 1), it adds the file name to whitelist.txt. In antivirusd.sh, the scan function checks whitelist.txt before checking each file and skips the file if its name is listed. The whitelist is a file, so it still works after the antivirus is stopped and started again.

Bonus: cron job
antivirus-cron.sh scans test_dir once and ends. Cron runs it again and again.

Before you start, cron must be installed and running:
    sudo apt install cron
    sudo systemctl enable --now cron

Steps:
1. Go to the lab2 folder.
2. Add the cron job:
    (crontab -l 2>/dev/null; echo "* * * * * sleep 23; $(pwd)/antivirus-cron.sh >> /tmp/av.log 2>&1") | crontab -
3. Check that it was added:
    crontab -l
4. To remove it, run crontab -e, delete the line, and save.

Cron can only start jobs at the beginning of a minute, so the job runs every minute and waits 23 seconds first.

Cron expression for every 3rd Friday of the month at 12:31 AM:
    31 0 15-21 * * [ "$(date +\%u)" -eq 5 ] && /full/path/to/antivirus-cron.sh
The 3rd Friday is always between the 15th and the 21st. The check after it makes sure the day is a Friday.

