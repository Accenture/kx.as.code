# Best Practices

When adding new component installations, consider the following.

- Any script that is created, must be re-runnable without breaking. It should have the necessary checks to see if something has already been executed successfully or not, eg. user creation etc.
- All temporary files used during the installation process, must be located in `/usr/share/kx.as.code/workspace`. You should use the `${installationWorkspace}`, rather than hard coding this path.
- Everything must be tied down to a specific version to avoid failure due to unmanaged upgrades later on - i.e. avoid the use of `latest`.
- It is recommended that `versions` and associated `checksums` (where applicable), are stored as `environment_variables` in `metadata.json`, rather than hard coded into the scripts. See the following [example](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/core/gopass/metadata.json){:target="\_blank"}.
- Use the available [central functions](../../Development/Available-Functions/) as much as possible to avoid repeating code and make use of the validations already in place. See also [here](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/core/gopass/install-and-configure-gopass.sh#L4-L11){:target="\_blank"} how those variables are used.
- Make use of the global standard variables such as `${installationWorkspace}`, `${baseDomain}`, `${baseUser}`, `${basePassword}`. The available global variables are defined in globalVariables.json and loaded via the function [getGlobalVariables()](../../Development/Available-Functions/#getglobalvariables). 
- All scripts must return `RC=1` if anything within fails during execution. This ensures the failure is sent to the RabbitMQ's failure queue, providing the user with the necessary information, and allowing for debugging and resolution, before moving the item from the `failure_queue` to the `retry_queue`. 