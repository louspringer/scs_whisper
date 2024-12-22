# Documentation for `set_conda_env_var.sh`

## Overview
The `set_conda_env_var.sh` script automates the process of setting environment variables for a Conda environment. It creates or updates activation and deactivation scripts to manage environment variables within the scope of a specific Conda environment.

## Key Features
- **Environment Isolation**: Variables are only available in the target Conda environment
- **Idempotent Setup**: Prevents duplicate entries when setting the same variable multiple times
- **Optional Git Integration**: Automatically commits changes if run within a Git repository
- **Automatic Cleanup**: Creates deactivation scripts to unset variables when leaving the environment

## Security Considerations
- **Git Integration**: The script automatically commits changes. DO NOT store sensitive values (passwords, API keys) this way
- **File Permissions**: For sensitive files (like private keys), ensure proper permissions (600 or more restrictive)
- **Variable Values**: Consider using environment-specific paths for sensitive files

## Usage
```bash
./set_conda_env_var.sh <environment_name> <variable_name> <variable_value>
```

### Parameters
- `environment_name`: Name of the target Conda environment
- `variable_name`: Name of the environment variable to set
- `variable_value`: Value to assign to the environment variable

### Examples
Setting up Snowflake authentication variables:
```bash
# Set the private key path (ensure the key file has 600 permissions)
chmod 600 ~/.ssh/snowflake.p8
./set_conda_env_var.sh sccs SNOWFLAKE_PRIVATE_KEY_PATH "~/.ssh/snowflake.p8"

# Set the authenticator type
./set_conda_env_var.sh sccs SNOWFLAKE_AUTHENTICATOR "SNOWFLAKE_JWT"
```

## What Happens
1. **Script Creation**:
   - Creates/updates `etc/conda/activate.d/env_vars.sh` in your Conda environment directory
   - Creates/updates `etc/conda/deactivate.d/env_vars.sh` in your Conda environment directory
   - Multiple variables accumulate in these scripts (they don't overwrite each other)
   
2. **On Environment Activation**:
   - Variables are automatically set to their specified values
   - Each variable is set independently
   
3. **On Environment Deactivation**:
   - Variables are automatically unset
   - All variables in the deactivation script are unset

4. **Git Integration** (if in a Git repository):
   - Changes are automatically committed
   - Commit message includes the variable and environment name
   - You can disable this by running in a directory outside the Git repository
   
## Important Notes
- **Existing Scripts**: If the variable already exists in the scripts, only that line is updated
- **Git Integration**: Only occurs if run within a Git repository
- **Idempotent Behavior**: Running the script multiple times with the same variable is safe
- **File Permissions**: Scripts are automatically made executable
- **Absolute Paths**: Consider using absolute paths for file locations to avoid resolution issues

## Error Handling
The script will fail with an error message if:
- The specified Conda environment doesn't exist
- You don't have write permissions for the environment directory
- The environment name, variable name, or value is missing
- Git operations fail (if in a repository)

## Testing the Configuration
1. Set a variable:
   ```bash
   ./set_conda_env_var.sh sccs TEST_VAR "test_value"
   ```

2. Activate the environment:
   ```bash
   conda activate sccs
   ```

3. Verify the variable:
   ```bash
   echo $TEST_VAR
   # Output: test_value
   ```

4. Deactivate to unset:
   ```bash
   conda deactivate
   ```

## Rolling Back Changes

### Using Git (if available)
```bash
# Find the commit that set the variable
git log --grep="Set TEST_VAR for Conda environment sccs"

# Revert the specific commit
git revert <commit-hash>
```

### Manual Cleanup
Find and edit/remove the scripts in your Conda environment:
```bash
# Get environment path
CONDA_ENV_PATH=$(conda env list | grep "^sccs " | awk '{print $2}')

# Remove the scripts (or edit them to remove specific variables)
rm -f "$CONDA_ENV_PATH/etc/conda/activate.d/env_vars.sh"
rm -f "$CONDA_ENV_PATH/etc/conda/deactivate.d/env_vars.sh"
```

## Example Python Code
```python
import os

# Access any environment variable you've set
var_value = os.getenv("YOUR_VAR_NAME")

if var_value is None:
    raise ValueError("Environment variable not set. Did you activate the correct environment?")

print(f"Variable value: {var_value}")
```

## Troubleshooting
- If variables aren't set, ensure you're in the correct environment
- Check script permissions in the Conda environment directory
- Verify the activation/deactivation scripts exist and are executable
- For Git-related issues, check if you're in a Git repository
- If using file paths, verify they're accessible from the activated environment
- For permission errors, check both the script and target directory permissions

For additional help or to report issues, please contact the maintainer.