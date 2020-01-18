#!/usr/bin/env bash

font_path="${HOME}/.local/share/fonts/nerd-fonts"
font_branch_file="${font_path}/.font_branch"
font_branch="2.0.0"

current_font_branch="$(cat "${font_branch_file}" 2> /dev/null)"
[[ "${current_font_branch}" != "${font_branch}" ]] && {
  [[ -d "${font_path}" ]] \
    && echo "Updating nerd-fonts (${current_font_branch} -> ${font_branch})" \
    || echo "Installing nerd-fonts"
  mkdir -p "${font_path}"
  echo -n "${font_branch}" > "${font_branch_file}"
  curl "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/${font_branch}/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete.ttf" \
    -o "${font_path}/Sauce Code Pro Nerd Font Complete.ttf"
  (fc-cache -f -v "${font_path}")
}
