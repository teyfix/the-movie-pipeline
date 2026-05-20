#!/usr/bin/env bash

set -euo pipefail

CMD_RENDER="cue cmd export ./shared/tools"
CMD_WATCH="watchexec -qe cue $CMD_RENDER"

init_data() {
  while IFS= read -r varname; do
    folder="${!varname}"

    mkdir -p "$folder"
    chown -R "$USERNAME:$USERNAME" "$folder"
  done < <(compgen -v | grep -E '^(DATADIR|CONFIGDIR)_')
}

init_config() {
  eval "$CMD_RENDER"
  eval "$CMD_WATCH" &
}

init_process() {
  if [ -f "$EXEC_CMD" ]; then
    exec su "$USERNAME" -s /bin/bash -- -c "/bin/bash '$EXEC_CMD'"
  else
    exec su "$USERNAME" -s /bin/bash -- -c "shopt -s globstar; $EXEC_CMD"
  fi
}

init_data
init_config
init_process
