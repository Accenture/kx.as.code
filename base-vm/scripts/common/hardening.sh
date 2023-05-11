#!/bin/bash -x

cisHardeningToRun="""
1.1.1.1
1.1.1.2
1.1.1.3
2.1.1.2
"""

### Initialize steps
git checkout cis repo....
sed....
cp...

for cisScriptId in ${cisHardeningToRun}
do

  # Map phaseId to installation directory
  case ${cisScriptId} in

      1.1.1.1)
          ....optional additional steps needed to fulfill the steps to make a test green....
          ;;

      2.1.1.2)
          ....optional additional steps needed to fulfill the steps to make a test green....
          ;;
      *)
  esac

  find /path/to/cis_scripts -n "${cisScriptId}_*.sh"
  ....code-tp-audit-and-run-script...

done

# run final audit with --all and store report oin workspace
... hardning.sh --audit-all ....

# Clean up
delete cis repo checked out in init steps....

