#!/usr/bin/env bash

set -Eeu

# Settings

fonts=(Hack)

#############

verlte() { [[ "$1" == "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" ]]; }
verlt() { [[ "$1" == "$2" ]] && return 1 || verlte "$1" "$2"; }

font_base_path="${HOME}/.local/share/fonts/nerd-fonts"
font_release="v2.0.0" # Set v2.0.0 as fallback

# Get the latest version from the GitHub releases API
releases="$(
  curl -s 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest'
)"
latest_font_release="$(
  echo -n "${releases}" | jq -r '.tag_name // empty' 2> /dev/null
)"

font_release="${latest_font_release:-${font_release}}"
[[ -z "${latest_font_release}" ]] &&
  echo "Failed to determine the latest nerd-fonts release;" \
      "assuming ${font_release} as the latest"

for font_name in "${fonts[@]}"; do
  font_release_file="${font_base_path}/${font_name}/.font_release"

  current_font_release="$(cat "${font_release_file}" 2> /dev/null || true)"
  if verlt "${current_font_release}" "${font_release}"; then
    [[ -d "${font_base_path}" && -f "${font_release_file}" ]] \
      && echo "Updating nerd-fonts/${font_name} (${current_font_release} -> ${font_release})" \
      || echo "Installing nerd-fonts/${font_name} (${font_release})"

    # Navigate to the font path so that curl can save the files
    pushd "${font_base_path}" > /dev/null

    # Extract the download URL
    font_url="$(
      echo -n "${releases}" \
        | jq -r ".assets[]
            | select(.name == \"${font_name}.zip\")
            | .browser_download_url // empty" 2> /dev/null
    )"

    [[ -z "${font_url}" ]] && {
      echo "Failed to obtain the download URL for ${font_name}.zip"
      exit 1
    }

    # Download the font archive
    echo "Downloading ${font_url}"
    curl -Lsf "${font_url}" -o "${font_name}.zip" || {
      echo "Failed to download ${font_name}.zip"
      exit 1
    }

    # Create the directory structure
    mkdir -p "${font_base_path}/${font_name}"

    # Extract the files
    unzip -d "${font_base_path}/${font_name}" "${font_name}.zip" || {
      echo "Failed to unzip ${font_name}.zip"
      rm -f "${font_name}.zip"
      exit 1
    }

    # Delete the font archive
    rm -f "${font_name}.zip"

    # Save installed release
    echo -n "${font_release}" > "${font_release_file}"

    # Restore the previous working directory (doesn't matter)
    popd > /dev/null
  fi
done

# Update the font cache
(fc-cache -f -v "${font_base_path}")
