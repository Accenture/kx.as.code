# Best Practices

When adding new component installations, consider the following.

- Any script that is created, must be re-runnable without breaking. It should have the necessary checks to see if something has already been executed successfully or not, eg. user creation etc.
- All temporary files used during the installation process, must be located in `/usr/share/kx.as.code/workspace`.
- Everything must be tired down to a specific version to avoid failure due to unmanaged upgrades later on - simply by the script pulling `latest`.
- It is recommended that `versions` and associated `checksums` (where applicable), are stored as `environment_variables` in `metadata.json`, rather than hard coded into the scripts.
- Scripts must have as little hard coded as possible, which means using standard variables such as `${installationWorkspace}`, `${baseDomain}`, `${baseUser}`, `${basePassword}` and so on.
- All scripts must return `RC=1` if anything within fails during execution. This ensures the failure is sent to the RabbitMQ's failure queue, providing the user with the necessary information, and allowing for debugging and resolution, before moving the item from the `failure_queue` to the `retry_queue`. 