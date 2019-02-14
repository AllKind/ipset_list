#!/usr/bin/env bash

# -----------------------------------------------------------------
# ipset set listing wrapper script
#
# https://github.com/AllKind/ipset_list
# https://sourceforge.net/projects/ipset-list/
# -----------------------------------------------------------------

# Copyright (C) 2013-2019 Mart Frauenlob aka AllKind (AllKind@fastest.cc)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# -----------------------------------------------------------------
# uninstaller for ipset_list
# -----------------------------------------------------------------

# ------------------------------------------------------------------------- #
# FUNCTIONS
# ------------------------------------------------------------------------- #

usage() {
printf "
USAGE: ${0##*/} [Option] [...]\n
Options:
-?, -h, --help                Show this usage instructions
-n, --no-act                  Perform a dry-run
-v, --verbose                 Verbose output
\n"
}

no_act() { # just print the command string
	printf "%s\n" "$*"
}

rem_dir() {
	${NOACT}command rm $VERBOSE -rf "$1"
}

rem_file() {
	${NOACT}command rm $VERBOSE -f "$1"
}

rem_empty_dir() {
# all done in a sub-shell, as we change shell options
(
	shopt -s nullglob
	shopt -s dotglob
	set +f
	# Check for empty files using arrays
	chk_files=(${1}/*)
	if (( ${#chk_files[*]} )); then
		if [[ $VERBOSE ]]; then
			printf "Directory \`%s' is not empty. Skipping it.\n" "$1"
		fi
	else
		${NOACT}command rmdir $VERBOSE "$1"
	fi
)
}

# ------------------------------------------------------------------------- #
# MAIN
# ------------------------------------------------------------------------- #

ME="ipset_list"
: ${PATH:=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin}

# parse arguments
unset NOACT VERBOSE
while (($#)); do
	case "$1" in
		"-?"|-h|--help) usage
			exit 0
		;;
		-n|--no-act) NOACT="no_act "
		;;
		-v|--verbose) VERBOSE="-v"
		;;
		*) usage
			exit 3
	esac
	shift
done

# install.bash created ${ME}-install.log, need the declarations from it
. ./${ME}-install.log || {
	printf "Cannot find ./${ME}-install.log. Aborting.\n" >&2
	exit 1
}

# check if the variable are defined
for f in SYSCONFDIR BINDIR BASHCOMPDIR CACHEDIR DATAROOTDIR MANDIR DOCDIR
do
	if [[ -z ${!f} ]]; then
		printf "Need variable \`%s'. Aborting.\n" "$f" >&2
		exit 1
	fi
done

# check for needed programs
for f in rm rmdir; do
	command -v $f &>/dev/null || {
		printf "Unable to find the \`$f' program in \$PATH.\n" >&2
		exit 1
	}
done

# warn about ownership - if not root
if ((EUID != 0)); then
	printf "Warning: Not running as root.\n"
fi

if [[ $NOACT ]]; then
	printf "\nNO ACT MODE - NOT UNINSTALLING!\n\n"
else
	printf "Starting uninstall\n"
fi

# start deletion
for f in SYSCONFDIR DOCDIR CACHEDIR; do
	rem_dir "${!f}/$ME"
done

for f in BINDIR; do
	rem_file "${!f}/$ME"
done

if [[ $BASHCOMPDIR = \~ ]]; then
	printf "bashcompdir is \`~'.\n\tRemember to manually remove completion from: \`%s'.\n" "~/.bash_completion"
else
	rem_file "${BASHCOMPDIR}/$ME"
fi


for f in "${MANDIR}"/man8/${ME}*.8; do
	rem_file "$f"
done

for f in 8; do
	rem_empty_dir "${MANDIR}/man${f}"
done

for f in BASHCOMPDIR BINDIR DOCDIR MANDIR SYSCONFDIR DATAROOTDIR
do
	rem_empty_dir "${!f}"
done

if [[ $PREFIX ]]; then
	rem_empty_dir "$PREFIX"
fi

printf "Finished uninstall\n"

