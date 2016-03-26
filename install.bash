#!/usr/bin/env bash

# -----------------------------------------------------------------
# ipset set listing wrapper script
#
# https://github.com/AllKind/ipset_list
# https://sourceforge.net/projects/ipset-list/
# -----------------------------------------------------------------

# Copyright (C) 2013-2016 Mart Frauenlob aka AllKind (AllKind@fastest.cc)
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
# installer for ipset_list
# -----------------------------------------------------------------

# bash check
if [ -z "$BASH" ]; then
	echo "\`BASH' variable is not available. Not running bash?"
	exit 1
fi

# shell options
set +f -o braceexpand
umask 0022

# variables
: ${PATH:=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin}
ME=ipset_list
BACKUP=
BASHCOMPDIR=
GROUP=
BINDIR=
DATAROOTDIR=
DOCDIR=
MANDIR=
NOACT=
OWNER=
OWNSH=
PREFIX=
SYSCONFDIR=
VERBOSE=

arr_args=( "$@" )

# ------------------------------------------------------------------------- #
# FUNCTIONS
# ------------------------------------------------------------------------- #

usage() {
printf "
USAGE: ${0##*/} [[Option] Option-argument] [...]\n
Options:
-?, -h, --help                Show this usage instructions
-b, --backup                  Create numbered backups (suffix=~)
-g, --group group_name        Set group ownership. Default: root
-n, --no-act                  Perform a dry-run
-o, --owner owner_name        Set ownership. Default: root
-v, --verbose                 Verbose output
--prefix /path                Prefix directory. Default: /usr/local
--bindir /path                Default: PREFIX/sbin
--datarootdir /path           Default: PREFIX/share
--docdir /path                Default: DATAROOTDIR/doc
--mandir /path                Default: DATAROOTDIR/man
--sysconfdir /path            Default: PREFIX/etc
--bashcompdir /path           Retrieved with pkg-config, or as fallback:
                              /etc/bash_completion.d, or ~/.bash_completion
\n"
}

no_act() { # just print the command string
printf "%s\n" "$*"
}

create_dirs() { # create all directory components
${NOACT}command install $VERBOSE $OWNSH -d "$@"
}

install_dir() { # install multiple source files to destination
local str_perm
case "$1" in
	-m|--mode)
		str_perm="-m $2"
		shift 2
	;;
esac
${NOACT}command install $VERBOSE $BACKUP $OWNSH $str_perm "$@"
}

install_file() { # install a single file
local str_perm
case "$1" in
	-m|--mode)
		str_perm="-m $2"
		shift 2
	;;
esac
${NOACT}command install $VERBOSE $BACKUP $OWNSH $str_perm -T "$@"
}

# ------------------------------------------------------------------------- #
# MAIN
# ------------------------------------------------------------------------- #

# parse arguments
while (($#)); do
	option="$1" opt_arg="$2"
	shift
	case "$option" in
		"-?"|-h|--help) usage
			exit 0
		;;
		-b|--backup) BACKUP="--backup=t"
			continue
		;;
		-g|--group) GROUP="$opt_arg" ;;
		-n|--no-act) NOACT="no_act "
			continue
		;;
		-o|--owner) OWNER="$opt_arg" ;;
		-v|--verbose) VERBOSE="-v"
			continue
		;;
		--bashcompdir) BASHCOMPDIR="$opt_arg" ;;
		--bindir) BINDIR="$opt_arg" ;;
		--datarootdir) DATAROOTDIR="$opt_arg" ;;
		--docdir) DOCDIR="$opt_arg" ;;
		--mandir) MANDIR="$opt_arg" ;;
		--prefix) PREFIX="$opt_arg" ;;
		--sysconfdir) SYSCONFDIR="$opt_arg" ;;
		*) usage
			exit 3
	esac
	if [[ $opt_arg ]]; then shift; fi
done

# set defaults
: ${PREFIX:=/usr/local}
: ${BINDIR:=${PREFIX}/sbin}
: ${DATAROOTDIR:=${PREFIX}/share}
: ${SYSCONFDIR:=${PREFIX}/etc}
: ${DOCDIR:=${DATAROOTDIR}/doc}
: ${MANDIR:=${DATAROOTDIR}/man}

: ${OWNER:=root}
: ${GROUP:=root}
OWNSH="--group=$GROUP --owner=$OWNER"

if [[ -z $BASHCOMPDIR ]]; then
	if command -v pkg-config &>/dev/null; then
		while :; do
			BASHCOMPDIR=$(command pkg-config --variable=completionsdir bash-completion) && break
			BASHCOMPDIR=$(command pkg-config --variable=compatdir bash-completion) && break
		done
	else
		while :; do
			[[ -e /etc/bash_completion.d ]] && BASHCOMPDIR=/etc/bash_completion.d && break
			BASHCOMPDIR='~' && break
		done
	fi

fi

# warning message on dry-run
if [[ $NOACT ]]; then
	printf "\nNO ACT MODE - NOT INSTALLING!\n\n"
fi

# check for install bin
command -v install &>/dev/null || {
	printf "Unable to find the \`install' binary in \$PATH.\n" >&2
	exit 1
}

# warn about ownership - if not root
if ((EUID != 0)); then
	printf "Not running as root. Not changing ownership/groups.\n"
	OWNSH=
fi

# create directories
create_dirs "${BINDIR}" "${SYSCONFDIR}/$ME" "${DOCDIR}/$ME" "${MANDIR}/man8" "${BASHCOMPDIR}"

# copy files
install_dir -m 0664 doc/*.8 "${MANDIR}/man8"
install_dir -m 0664 doc/*.html "${DOCDIR}/${ME}"
install_file -m 0755 "${ME}" "${BINDIR}/$ME"
install_file -m 0644 "${ME}.conf" "${SYSCONFDIR}/${ME}/${ME}.conf"

if [[ $BASHCOMPDIR = ~ ]]; then
	printf "bashcompdir is \`~', adding completion to \`%s'.\n\tRemember to manually remove it on uninstall, or re-install.\n" "~/.bash_completion"
	if ! [[ $NOACT ]]; then
		command cat ip-array_bash_completion >> ~/.bash_completion
	fi
else
	install_file -m 0644 bash_completion/"$ME" "$BASHCOMPDIR/$ME"
fi

if ! [[ $NOACT ]]; then
	# create versions file
	printf "Creating version file: \`${SYSCONFDIR}/${ME}/${ME}_version'\n"
	(set +C; "${BINDIR}/$ME" -v > "${SYSCONFDIR}/${ME}/${ME}_version")

	# create log file, to be re-used by uninstall.bash
	printf "Creating \`./${ME}-install.log' - Will need this for uninstallation!\n"
	(set +C; printf '#!/usr/bin/env bash\n\n' > ./${ME}-install.log)
	printf "# install arguments: %s\n\n" "${arr_args[*]}" >> ./${ME}-install.log
	for var in PREFIX BASHCOMPDIR BINDIR DATAROOTDIR DOCDIR MANDIR SYSCONFDIR; do
		declare -p "$var" >> ./${ME}-install.log
	done
fi

printf "Finished Install\n"
exit 0

