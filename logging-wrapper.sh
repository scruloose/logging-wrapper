#!/bin/bash

# This is /usr/local/bin/logging-wrapper.sh
# It runs a program and logs stdout, stderr, and a snippet of 
# /var/log/messages to a date/timestamped file in ~/.local/logs/
# using tee so you can watch it all in the terminal at the same time.

# REMINDER: 'tail' will fail unless user is in group 'adm' (Debian)

# If this is set to 1, we'll only capture if there isn't already an
# instance of $PROGRAM running. Useful for programs where subsequent
# windows behave as clients of the existing instance.
# To log all instances without checking, set this to 0
SINGLEINSTANCE=1

USAGE="$(basename $0) target-program [arguments for target-program]"
PARENTDIR="$HOME/.local"
LOGDIR="$PARENTDIR/logs"


# If no program to run is specified, display usage reminder and exit.
if [ "$#" == "0" ]; then
	printf "You need to specify a program to run!\n"
	printf "Usage:\n\t$USAGE\n"
	exit 1
fi

# If invalid program (not an executable) is specified, remind and exit.
if ! builtin type -P "$1" &> /dev/null; then
	printf "$1 does not appear to be a valid program.\n"
	printf "Usage:\n\t$USAGE\n"
	exit 1
fi

# Capture the program name from input parameters, then drop it from
# the array. All remaining parameters will be passed to the program.
PROGRAM="$1"; shift

LOGFILE="$LOGDIR/$PROGRAM-$(date +%Y%m%d-%H%M).log"

# If single-instance checking is on, look for existing instances of
# $PROGRAM. If found, launch the program with no logging.
if [ "$SINGLEINSTANCE" -eq 1 ]; then
	printf "Checking for already-running instances of %s.\n" "$PROGRAM"
	if PID=$(pgrep "$PROGRAM"); then
		printf "Found PID %s. NOT capturing logs.\n" "$PID"
		"$PROGRAM" "$@" &
		exit 0
	else
		printf "None found. Proceeding with capture.\n"
	fi
fi

# Halt and catch fire if user's ~/.local/ dir is not found.
if [ ! -d "$PARENTDIR" ]; then
	printf "Uh-oh, directory %s does not exist. Aborting.\n" "$PARENTDIR"
	exit 1
fi

# If ~/.local does not contain a logs/ subdir, attempt to create it;
# halt and catch fire if that fails.
if [ ! -d "$LOGDIR" ]; then
	printf "Log directory %s not found. Creating it...\n" "$LOGDIR"
	if ! mkdir "$LOGDIR"; then
		printf "Uh-oh, failed to create %s. Aborting.\n" "$LOGDIR"
		exit 1
	else
		printf "Success! Logging to %s\n" "$LOGFILE"
	fi
else
	printf "Loggging to %s\n" $LOGFILE
fi

# Log the date & time of program start.
printf "%s launched at %s\n****START CAPTURE****\n" "$PROGRAM" "$(date +%Y-%m-%d\ %H:%M)" | tee "$LOGFILE"

# Run the program, capturing stdout and stderr to the log file.
"$PROGRAM" "$@" 2>&1 | tee -a "$LOGFILE" 

# Log the date & time of program exit, so we can see how long it ran.
printf "****END CAPTURE****\n%s exited at %s\nGrabbing /var/log/messages.\n" "$PROGRAM" "$(date +%Y-%m-%d\ %H:%M)" | tee -a "$LOGFILE"

# Append the last 20 entries from /var/log/messages for good measure
# but don't spam the console with them.
tail -20 /var/log/messages >> "$LOGFILE" 2>&1

exit 0
