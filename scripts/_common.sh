#
# Common Variables
#

APPNAME="ts3server"

# Teamspeak 3 Server version
# TODO: Add mariadb version
TS3S_VERSION="3.13.7"

# TODO: Add dependencies here
# libmariadb

# Remote URL to fetch teamspeak tar.bz2 archive
SOURCE_URL="http://files.teamspeak-services.com/releases/server/${TS3S_VERSION}/teamspeak3-server_linux_ARCH-${TS3S_VERSION}.tar.bz2"

# TeamSpeak 3 Server tar.bz2 checksums
# TODO: get url for checksums
declare -A SOURCE_SHA256=( [x86]="68c1033a7bc178a7f31bc94316153c2390d8806e7722c08304c576314c898b68" \
						   [amd64]="775a5731a9809801e4c8f9066cd9bc562a1b368553139c1249f2a0740d50041e" )


#
# Common Helpers
#

# Download and extract Teamspeak 3 server source
# usage: extract_ts3server ARCH DESTDIR [USER]
extract_ts3server() {
	local ARCH=$1
	local DESTDIR=$2
	local USER=${3:-admin} # make sure parent script has admin var
	
	# Retrieve tar.bz2
	ts3server_src="/tmp/ts3server.tar.bz2"
	rm -f "$ts3server_src"
	
	# Download source and verify checksum
	wget -q -O "$ts3server_src" "$(sed -e "s/ARCH/${ARCH}/g" <<< $SOURCE_URL)" \
	   || ynh_die "Unable to download teamspeak 3 server source."
	echo "${SOURCE_SHA256[${ARCH}]} $ts3server_src" | sha256sum -c >/dev/null \
	   || ynh_die "Invalid checksum of Teamspeak 3 server source."
	
	# Extract source to specified directory
	exec_as "$USER" tar -xjf "$ts3server_src" -C "$DESTDIR" --strip-components 1 \
		|| ynh_die "Unable to extract Teamspeak 3 server source."
	rm -f "$ts3server_src"
}

# Execute a command as another user (sourced from owncloud_ynh)
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local USER=$1
  shift 1

  if [[ $USER = $(whoami) ]]; then
    eval "$@"
  else
    # use sudo twice to be root and be allowed to use another user
    sudo sudo -u "$USER" "$@"
  fi
}
