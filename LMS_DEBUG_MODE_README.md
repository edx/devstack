# LMS Debug Mode Setup

This document describes how to run the LMS service in normal or debug mode using the Devstack Makefile.

## Quick Start

### Normal Mode (Default)
To run the LMS service in normal mode without debugpy:
```bash
make dev.up.lms
```

### Debug Mode with debugpy
To run the LMS service in debug mode with debugpy enabled:
```bash
make dev.debug.lms
```

## How It Works

### Implementation Details

1. **LMS Runner Script** (`lms-run.sh`)
   - A bash script that determines whether to run in normal or debug mode
   - Checks the `DEVSTACK_DEBUG` environment variable
   - If set to `debug`: Installs and runs with debugpy on port 44568
   - If set to `normal` (default): Runs without debugpy

2. **Docker Compose Configuration**
   - The LMS service command now calls `lms-run.sh` instead of hardcoding debugpy
   - The `DEVSTACK_DEBUG` environment variable is passed to the container
   - Port 44568 remains exposed in docker-compose.yml for debugpy

3. **Makefile Targets**
   - `dev.up.%`: Standard targets for normal mode (unchanged)
   - `dev.debug.%`: New targets that set `DEVSTACK_DEBUG=debug` before starting services
   - Examples:
     - `make dev.up.lms` - Start LMS normally
     - `make dev.debug.lms` - Start LMS with debugpy
     - `make dev.debug.lms+discovery` - Start LMS with debugpy and discovery in normal mode

## VS Code Debugging

With the LMS running in debug mode, you can attach VS Code debugger:

1. Ensure `make dev.debug.lms` is running
2. In VS Code, go to the Debug view (Ctrl+Shift+D)
3. Select "LMS Debugpy" configuration
4. Click the play button to attach the debugger

The debugger will wait for client attachment when configured with `--wait-for-client` flag.

## Switching Between Modes

To switch from one mode to another:

```bash
# Kill existing LMS container
docker-compose kill lms

# Start in the desired mode
make dev.up.lms        # Normal
# or
make dev.debug.lms     # Debug with debugpy
```

## Troubleshooting

- **Debugpy port already in use**: Ensure no other process is using port 44568
- **Script permission issues**: The `lms-run.sh` script will be executed inside the container, so host permissions don't matter
- **Environment variable not passed**: Verify using `docker-compose exec lms env | grep DEVSTACK_DEBUG`

## Technical Notes

- The `DEVSTACK_DEBUG` environment variable only affects LMS service
- Other services (cms, lms-worker, etc.) are not affected by this flag
- For services other than LMS, standard `dev.up` and `dev.debug` targets still apply the environment variable, but it won't affect their behavior unless they also implement similar logic
