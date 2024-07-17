# Helper script to rename entities appearing in configuration and scripts
#
# One limitation: the find or replace strings cannot contain the %
# character.  If the --dry-run flag is passed, prints out the changes
# that would be applied.

declare -a DIRS
if [[ ! -v DIRS ]]; then
    DIRS=(scripts .github)
fi
if [[ "$1" = "--dry-run" || "$1" = "-d" ]]; then
    shift
    [[ -n "$1" ]] && grep -lREZ "$1" "${DIRS[@]}" | xargs -r -0 sed -n "\%$1%{F; p; s%$1%$2%p}"
else
    grep -lREZ "$1" "${DIRS[@]}" | xargs -r -0 sed -i "s%$1%$2%"
fi
