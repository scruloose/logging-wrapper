# logging-wrapper
A wrapper script to launch a program and capture debugging info to a log file. The logfile name follows the format `<program-name><timestamp>.log`, and the file will be put in `~/.local/logs/`. logging-wrapper will create the `logs/` directory if needed, but it will exit with an error if it doesn't find `~/.local`.)

To use logging-wrapper, put it in your $PATH somewhere (I like /usr/local/bin), remember to set execute permission, and type `logging-wrapper.sh <program> [options and arguments for <program>]`

**NOTE:** logging-wrapper will try to log the last 20 entries from `/var/log/messages` when the target program exits, to get a glimpse of what the system is up to at the moment of a crash. This will only succeed if the user running the script has read access to that file. On Debian, the easy way to accomplisth that is to add the user to group 'adm'.

When launched in a terminal window, logging-wrapper will print messages about its own activity *and* a copy of everything it captures to that window.

As-is, the script will check for running instances of the target program and only capture log info for the first instance. This prevents generating a bunch of useless log files for programs where opening additional windows spawns client instances which connect to the running instance like a server (in which case all debug output comes from the first running istance). If you want to skip that check and just log every instance, edit the script and change `SINGLEINSTANCE=` from 1 to 0. (Suitable for programs where subsequent instances are independent processes that may produce their own debugging output.)

For prolonged debugging of a graphical program, (eg trying to track down an infrequent fatal crash bug) you can create a menu item in your desktop environment of choice by duplicating the target program's entry and prepending `logging-wrapper.sh` to the command in the duplicate entry (and name it `<program> (logging)` or similar). Any options and arguments received by the script will be passed on as-is to the program when it's launched. Setting the logging-wrapper entry as default action for any MIME types associated with the target program should work too.

logging-wrapper does not do any rotation of the captured log files, deletion of old log files, or anything like that. Managing the files generated is left entirely up to the user!

Happy hunting!

(No warranty, express or implied; use at own risk; you know the drill.)
