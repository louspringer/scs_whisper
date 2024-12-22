#!/bin/bash
#!/bin/bash

# Input arguments
ENV_NAME=$1
VAR_NAME=$2
VAR_VALUE=$3

# Check if arguments are provided
if [ -z "$ENV_NAME" ] || [ -z "$VAR_NAME" ] || [ -z "$VAR_VALUE" ]; then
  echo "Usage: $0 <environment_name> <variable_name> <variable_value>"
  exit 1
fi

# Get the path to the Conda environment
CONDA_ENV_PATH=$(conda env list | grep "^$ENV_NAME " | awk '{print $2}')

if [ -z "$CONDA_ENV_PATH" ]; then
  echo "Error: Conda environment '$ENV_NAME' not found."
  exit 1
fi

# Define paths
ACTIVATE_SCRIPT="$CONDA_ENV_PATH/etc/conda/activate.d/env_vars.sh"
DEACTIVATE_SCRIPT="$CONDA_ENV_PATH/etc/conda/deactivate.d/env_vars.sh"

# Ensure directories exist
mkdir -p "$(dirname "$ACTIVATE_SCRIPT")" "$(dirname "$DEACTIVATE_SCRIPT")"

# Make scripts idempotent
if ! grep -q "export $VAR_NAME=" "$ACTIVATE_SCRIPT" 2>/dev/null; then
  echo "#!/bin/bash" > "$ACTIVATE_SCRIPT" # Reset script if creating fresh
  echo "export $VAR_NAME=\"$VAR_VALUE\"" >> "$ACTIVATE_SCRIPT"
fi

if ! grep -q "unset $VAR_NAME" "$DEACTIVATE_SCRIPT" 2>/dev/null; then
  echo "#!/bin/bash" > "$DEACTIVATE_SCRIPT" # Reset script if creating fresh
  echo "unset $VAR_NAME" >> "$DEACTIVATE_SCRIPT"
fi

# Ensure scripts are executable
chmod +x "$ACTIVATE_SCRIPT" "$DEACTIVATE_SCRIPT"

# Integrate with Git
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add "$ACTIVATE_SCRIPT" "$DEACTIVATE_SCRIPT"
  git commit -m "Set $VAR_NAME for Conda environment $ENV_NAME"
  echo "Changes committed to Git. Use 'git restore' or 'git reset' to roll back if needed."
else
  echo "Git repository not detected. Scripts updated without version control."
fi

echo "Environment variable '$VAR_NAME' set to '$VAR_VALUE' for Conda environment '$ENV_NAME'."
