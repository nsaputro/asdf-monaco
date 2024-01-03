#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/Dynatrace/dynatrace-configuration-as-code"
TOOL_NAME="monaco"
TOOL_TEST="monaco version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version original_fname platform arch url
	version="$1"
	platform="$(get_platform)"
	arch="$(get_arch)"
	original_fname="$TOOL_NAME-${platform}-${arch}"

	url="$GH_REPO/releases/download/v${version}/${original_fname}"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$ASDF_DOWNLOAD_PATH/$original_fname" -C - "$url" || fail "Could not download $url"

	#download shasum
	curl "${curl_opts[@]}" -o "$ASDF_DOWNLOAD_PATH/$original_fname.sha256" -C - "$url.sha" || fail "Could not download $url.sha"

	check_shasum

	mv "$ASDF_DOWNLOAD_PATH/$original_fname" "$ASDF_DOWNLOAD_PATH/$TOOL_NAME"
	chmod +x "$ASDF_DOWNLOAD_PATH/$TOOL_NAME"
}

get_platform() {
	local kernel
	kernel="$(uname -s)"
	if [[ ${OSTYPE} == "msys" || ${kernel} == "CYGWIN"* || ${kernel} == "MINGW"* ]]; then
		echo windows
	else
		uname | tr '[:upper:]' '[:lower:]'
	fi
}

get_arch() {
	local arch
	arch=$(uname -m)
	if [[ ${arch} == "arm64" ]] || [[ ${arch} == "aarch64" ]]; then
		echo "arm64"
	elif [[ ${arch} == *"arm"* ]] || [[ ${arch} == *"aarch"* ]]; then
		echo "arm"
	elif [[ ${arch} == *"386"* ]]; then
		echo "386"
	else
		echo "amd64"
	fi
}

check_shasum() {
	local sha_cmd

	if command -v sha256sum >/dev/null; then
		sha_cmd=(sha256sum)
	elif command -v shasum >/dev/null; then
		sha_cmd=(shasum -a 256)
	else
		echo "WARNING: sha256sum/shasum program not found - unable to checksum. Proceed with caution."
		return 0
	fi

	(
		echo "Checking sha512 sum..."
		cd "${ASDF_DOWNLOAD_PATH}" || exit 1
		"${sha_cmd[@]}" -c ./*.sha256
	)
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		check_shasum

		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
