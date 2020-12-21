#!/bin/bash -eux

# Install Visual Studio Code editor
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install -y apt-transport-https
sudo apt-get update -y
sudo apt-get install -y code

# Create the VSCode user config directory
sudo mkdir -p /home/$VM_USER/.config/Code/User

# Install fonts for VSCODE terminal
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
sudo mv *.ttf /usr/share/fonts/truetype
sudo fc-cache -vf /usr/share/fonts/

# Switch off telemetry consent
sudo bash -c "cat <<EOF > /home/$VM_USER/.config/Code/User/settings.json
{
    \"workbench.startupEditor\": \"newUntitledFile\",
    \"telemetry.enableCrashReporter\": false,
    \"telemetry.enableTelemetry\": false,
    \"window.zoomLevel\": 1,
    \"terminal.integrated.fontFamily\": \"MesloLGS NF\"
}
EOF"

sudo mkdir -p /home/$VM_USER/.vscode/
sudo bash -c "cat <<EOF > /home/$VM_USER/.vscode/KX.AS.CODE.code-workspace
{
	\"folders\": [
		{
			\"path\": \"../Documents/kx.as.code_source\"
		},
		{
			\"path\": \"../Documents/kx.as.code_docs\"
		},
		{
			\"path\": \"../Documents/kx.as.code_techradar\"
		}
	],
	\"settings\": {}
}
EOF"

# Configure KX.AS.CODE repository into VSCode workspace
sudo bash -c "cat <<EOF > /home/$VM_USER/.config/Code/storage.json
{
  \"telemetry.machineId\": \"ba93989be179b3e43cc230b4a094b49eb1989492ba4574d68dbc017d2acda682\",
  \"openedPathsList\": {
    \"workspaces3\": [
      {
        \"id\": \"d1b9a0d329ac9faccadc5afb54ee2eba\",
        \"configURIPath\": \"file:///home/$VM_USER/.vscode/KX.AS.CODE.code-workspace\"
      },
      \"file:///home/$VM_USER/Documents/kx.as.code_source\"
    ],
    \"files2\": [

    ]
  },
  \"lastKnownMenubarData\": {
    \"menus\": {
      \"File\": {
        \"items\": [
          {
            \"id\": \"workbench.action.files.newUntitledFile\",
            \"label\": \"&&New File\"
          },
          {
            \"id\": \"workbench.action.newWindow\",
            \"label\": \"New &&Window\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.files.openFile\",
            \"label\": \"&&Open File...\"
          },
          {
            \"id\": \"workbench.action.files.openFolder\",
            \"label\": \"Open &&Folder...\"
          },
          {
            \"id\": \"workbench.action.openWorkspace\",
            \"label\": \"Open Wor&&kspace...\"
          },
          {
            \"id\": \"\",
            \"label\": \"Open &&Recent\",
            \"submenu\": {
              \"items\": [
                {
                  \"id\": \"workbench.action.reopenClosedEditor\",
                  \"label\": \"&&Reopen Closed Editor\",
                  \"enabled\": false
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"openRecentWorkspace\",
                  \"uri\": {
                    \"\$mid\": 1,
                    \"fsPath\": \"/home/$VM_USER/.vscode/KX.AS.CODE.code-workspace\",
                    \"external\": \"file:///home/$VM_USER/.vscode/KX.AS.CODE.code-workspace\",
                    \"path\": \"/home/$VM_USER/.vscode/KX.AS.CODE.code-workspace\",
                    \"scheme\": \"file\"
                  },
                  \"enabled\": true,
                  \"label\": \"~/.vscode/KX.AS.CODE (Workspace)\"
                },
                {
                  \"id\": \"openRecentFolder\",
                  \"uri\": {
                    \"\$mid\": 1,
                    \"path\": \"/home/$VM_USER/Documents/kx.as.code_source\",
                    \"scheme\": \"file\"
                  },
                  \"enabled\": true,
                  \"label\": \"~/Documents/kx.as.code_source\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.openRecent\",
                  \"label\": \"&&More...\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.clearRecentFiles\",
                  \"label\": \"&&Clear Recently Opened\"
                }
              ]
            }
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"addRootFolder\",
            \"label\": \"A&&dd Folder to Workspace...\"
          },
          {
            \"id\": \"workbench.action.saveWorkspaceAs\",
            \"label\": \"Save Workspace As...\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.files.save\",
            \"label\": \"&&Save\"
          },
          {
            \"id\": \"workbench.action.files.saveAs\",
            \"label\": \"Save &&As...\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.files.saveAll\",
            \"label\": \"Save A&&ll\",
            \"enabled\": false
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.toggleAutoSave\",
            \"label\": \"A&&uto Save\"
          },
          {
            \"id\": \"\",
            \"label\": \"&&Preferences\",
            \"submenu\": {
              \"items\": [
                {
                  \"id\": \"workbench.action.openSettings\",
                  \"label\": \"&&Settings\"
                },
                {
                  \"id\": \"settings.filterByOnline\",
                  \"label\": \"&&Online Services Settings\"
                },
                {
                  \"id\": \"workbench.view.extensions\",
                  \"label\": \"&&Extensions\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.openGlobalKeybindings\",
                  \"label\": \"Keyboard Shortcuts\"
                },
                {
                  \"id\": \"workbench.extensions.action.showRecommendedKeymapExtensions\",
                  \"label\": \"&&Keymaps\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.openSnippets\",
                  \"label\": \"User &&Snippets\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.selectTheme\",
                  \"label\": \"&&Color Theme\"
                },
                {
                  \"id\": \"workbench.action.selectIconTheme\",
                  \"label\": \"File &&Icon Theme\"
                }
              ]
            }
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.files.revert\",
            \"label\": \"Re&&vert File\"
          },
          {
            \"id\": \"workbench.action.closeActiveEditor\",
            \"label\": \"&&Close Editor\"
          },
          {
            \"id\": \"workbench.action.closeFolder\",
            \"label\": \"Close &&Workspace\"
          },
          {
            \"id\": \"workbench.action.closeWindow\",
            \"label\": \"Clos&&e Window\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.quit\",
            \"label\": \"E&&xit\"
          }
        ]
      },
      \"Edit\": {
        \"items\": [
          {
            \"id\": \"undo\",
            \"label\": \"&&Undo\"
          },
          {
            \"id\": \"redo\",
            \"label\": \"&&Redo\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"editor.action.clipboardCutAction\",
            \"label\": \"Cu&&t\"
          },
          {
            \"id\": \"editor.action.clipboardCopyAction\",
            \"label\": \"&&Copy\"
          },
          {
            \"id\": \"editor.action.clipboardPasteAction\",
            \"label\": \"&&Paste\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"actions.find\",
            \"label\": \"&&Find\"
          },
          {
            \"id\": \"editor.action.startFindReplaceAction\",
            \"label\": \"&&Replace\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.findInFiles\",
            \"label\": \"Find &&in Files\"
          },
          {
            \"id\": \"workbench.action.replaceInFiles\",
            \"label\": \"Replace &&in Files\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"editor.action.commentLine\",
            \"label\": \"&&Toggle Line Comment\"
          },
          {
            \"id\": \"editor.action.blockComment\",
            \"label\": \"Toggle &&Block Comment\"
          },
          {
            \"id\": \"editor.emmet.action.expandAbbreviation\",
            \"label\": \"Emmet: E&&xpand Abbreviation\"
          },
          {
            \"id\": \"workbench.action.showEmmetCommands\",
            \"label\": \"E&&mmet...\"
          }
        ]
      },
      \"Selection\": {
        \"items\": [
          {
            \"id\": \"editor.action.selectAll\",
            \"label\": \"&&Select All\"
          },
          {
            \"id\": \"editor.action.smartSelect.expand\",
            \"label\": \"&&Expand Selection\"
          },
          {
            \"id\": \"editor.action.smartSelect.shrink\",
            \"label\": \"&&Shrink Selection\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"editor.action.copyLinesUpAction\",
            \"label\": \"&&Copy Line Up\"
          },
          {
            \"id\": \"editor.action.copyLinesDownAction\",
            \"label\": \"Co&&py Line Down\"
          },
          {
            \"id\": \"editor.action.moveLinesUpAction\",
            \"label\": \"Mo&&ve Line Up\"
          },
          {
            \"id\": \"editor.action.moveLinesDownAction\",
            \"label\": \"Move &&Line Down\"
          },
          {
            \"id\": \"editor.action.duplicateSelection\",
            \"label\": \"&&Duplicate Selection\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"editor.action.insertCursorAbove\",
            \"label\": \"&&Add Cursor Above\"
          },
          {
            \"id\": \"editor.action.insertCursorBelow\",
            \"label\": \"A&&dd Cursor Below\"
          },
          {
            \"id\": \"editor.action.insertCursorAtEndOfEachLineSelected\",
            \"label\": \"Add C&&ursors to Line Ends\"
          },
          {
            \"id\": \"editor.action.addSelectionToNextFindMatch\",
            \"label\": \"Add &&Next Occurrence\"
          },
          {
            \"id\": \"editor.action.addSelectionToPreviousFindMatch\",
            \"label\": \"Add P&&revious Occurrence\"
          },
          {
            \"id\": \"editor.action.selectHighlights\",
            \"label\": \"Select All &&Occurrences\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.toggleMultiCursorModifier\",
            \"label\": \"Switch to Ctrl+Click for Multi-Cursor\"
          },
          {
            \"id\": \"editor.action.toggleColumnSelection\",
            \"label\": \"Column &&Selection Mode\"
          }
        ]
      },
      \"View\": {
        \"items\": [
          {
            \"id\": \"workbench.action.showCommands\",
            \"label\": \"&&Command Palette...\"
          },
          {
            \"id\": \"workbench.action.openView\",
            \"label\": \"&&Open View...\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"\",
            \"label\": \"&&Appearance\",
            \"submenu\": {
              \"items\": [
                {
                  \"id\": \"workbench.action.toggleFullScreen\",
                  \"label\": \"&&Full Screen\"
                },
                {
                  \"id\": \"workbench.action.toggleZenMode\",
                  \"label\": \"Zen Mode\"
                },
                {
                  \"id\": \"workbench.action.toggleCenteredLayout\",
                  \"label\": \"Centered Layout\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.toggleMenuBar\",
                  \"label\": \"Show Menu &&Bar\",
                  \"checked\": true
                },
                {
                  \"id\": \"workbench.action.toggleSidebarVisibility\",
                  \"label\": \"Show &&Side Bar\",
                  \"checked\": true
                },
                {
                  \"id\": \"workbench.action.toggleStatusbarVisibility\",
                  \"label\": \"Show S&&tatus Bar\",
                  \"checked\": true
                },
                {
                  \"id\": \"workbench.action.toggleActivityBarVisibility\",
                  \"label\": \"Show &&Activity Bar\",
                  \"checked\": true
                },
                {
                  \"id\": \"workbench.action.toggleEditorVisibility\",
                  \"label\": \"Show &&Editor Area\",
                  \"checked\": true
                },
                {
                  \"id\": \"workbench.action.togglePanel\",
                  \"label\": \"Show &&Panel\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.toggleSidebarPosition\",
                  \"label\": \"&&Move Side Bar Right\"
                },
                {
                  \"id\": \"workbench.action.positionPanelLeft\",
                  \"label\": \"Move Panel Left\"
                },
                {
                  \"id\": \"workbench.action.positionPanelRight\",
                  \"label\": \"Move Panel Right\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.zoomIn\",
                  \"label\": \"&&Zoom In\"
                },
                {
                  \"id\": \"workbench.action.zoomOut\",
                  \"label\": \"&&Zoom Out\"
                },
                {
                  \"id\": \"workbench.action.zoomReset\",
                  \"label\": \"&&Reset Zoom\"
                }
              ]
            }
          },
          {
            \"id\": \"\",
            \"label\": \"Editor &&Layout\",
            \"submenu\": {
              \"items\": [
                {
                  \"id\": \"workbench.action.splitEditorUp\",
                  \"label\": \"Split &&Up\"
                },
                {
                  \"id\": \"workbench.action.splitEditorDown\",
                  \"label\": \"Split &&Down\"
                },
                {
                  \"id\": \"workbench.action.splitEditorLeft\",
                  \"label\": \"Split &&Left\"
                },
                {
                  \"id\": \"workbench.action.splitEditorRight\",
                  \"label\": \"Split &&Right\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.editorLayoutSingle\",
                  \"label\": \"&&Single\"
                },
                {
                  \"id\": \"workbench.action.editorLayoutTwoColumns\",
                  \"label\": \"&&Two Columns\"
                },
                {
                  \"id\": \"workbench.action.editorLayoutThreeColumns\",
                  \"label\": \"T&&hree Columns\"
                },
                {
                  \"id\": \"workbench.action.editorLayoutTwoRows\",
                  \"label\": \"T&&wo Rows\"
                },
                {
                  \"id\": \"workbench.action.editorLayoutThreeRows\",
                  \"label\": \"Three &&Rows\"
                },
                {
                  \"id\": \"workbench.action.editorLayoutTwoByTwoGrid\",
                  \"label\": \"&&Grid (2x2)\"
                },
                {
                  \"id\": \"workbench.action.editorLayoutTwoRowsRight\",
                  \"label\": \"Two R&&ows Right\"
                },
                {
                  \"id\": \"workbench.action.editorLayoutTwoColumnsBottom\",
                  \"label\": \"Two &&Columns Bottom\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.toggleEditorGroupLayout\",
                  \"label\": \"Flip &&Layout\"
                }
              ]
            }
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.view.explorer\",
            \"label\": \"&&Explorer\"
          },
          {
            \"id\": \"workbench.view.search\",
            \"label\": \"&&Search\"
          },
          {
            \"id\": \"workbench.view.scm\",
            \"label\": \"S&&CM\"
          },
          {
            \"id\": \"workbench.view.debug\",
            \"label\": \"&&Run\"
          },
          {
            \"id\": \"workbench.view.extensions\",
            \"label\": \"E&&xtensions\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.output.toggleOutput\",
            \"label\": \"&&Output\"
          },
          {
            \"id\": \"workbench.debug.action.toggleRepl\",
            \"label\": \"De&&bug Console\"
          },
          {
            \"id\": \"workbench.action.terminal.toggleTerminal\",
            \"label\": \"&&Terminal\"
          },
          {
            \"id\": \"workbench.actions.view.problems\",
            \"label\": \"&&Problems\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"editor.action.toggleWordWrap\",
            \"label\": \"Toggle &&Word Wrap\"
          },
          {
            \"id\": \"editor.action.toggleMinimap\",
            \"label\": \"Show &&Minimap\",
            \"checked\": true
          },
          {
            \"id\": \"breadcrumbs.toggle\",
            \"label\": \"Show &&Breadcrumbs\",
            \"checked\": true
          },
          {
            \"id\": \"editor.action.toggleRenderWhitespace\",
            \"label\": \"&&Render Whitespace\",
            \"checked\": true
          },
          {
            \"id\": \"editor.action.toggleRenderControlCharacter\",
            \"label\": \"Render &&Control Characters\"
          }
        ]
      },
      \"Go\": {
        \"items\": [
          {
            \"id\": \"workbench.action.navigateBack\",
            \"label\": \"&&Back\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.navigateForward\",
            \"label\": \"&&Forward\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.navigateToLastEditLocation\",
            \"label\": \"&&Last Edit Location\",
            \"enabled\": false
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"\",
            \"label\": \"Switch &&Editor\",
            \"submenu\": {
              \"items\": [
                {
                  \"id\": \"workbench.action.nextEditor\",
                  \"label\": \"&&Next Editor\"
                },
                {
                  \"id\": \"workbench.action.previousEditor\",
                  \"label\": \"&&Previous Editor\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.openNextRecentlyUsedEditor\",
                  \"label\": \"&&Next Used Editor\"
                },
                {
                  \"id\": \"workbench.action.openPreviousRecentlyUsedEditor\",
                  \"label\": \"&&Previous Used Editor\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.nextEditorInGroup\",
                  \"label\": \"&&Next Editor in Group\"
                },
                {
                  \"id\": \"workbench.action.previousEditorInGroup\",
                  \"label\": \"&&Previous Editor in Group\"
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.openNextRecentlyUsedEditorInGroup\",
                  \"label\": \"&&Next Used Editor in Group\"
                },
                {
                  \"id\": \"workbench.action.openPreviousRecentlyUsedEditorInGroup\",
                  \"label\": \"&&Previous Used Editor in Group\"
                }
              ]
            }
          },
          {
            \"id\": \"\",
            \"label\": \"Switch &&Group\",
            \"submenu\": {
              \"items\": [
                {
                  \"id\": \"workbench.action.focusFirstEditorGroup\",
                  \"label\": \"Group &&1\"
                },
                {
                  \"id\": \"workbench.action.focusSecondEditorGroup\",
                  \"label\": \"Group &&2\"
                },
                {
                  \"id\": \"workbench.action.focusThirdEditorGroup\",
                  \"label\": \"Group &&3\",
                  \"enabled\": false
                },
                {
                  \"id\": \"workbench.action.focusFourthEditorGroup\",
                  \"label\": \"Group &&4\",
                  \"enabled\": false
                },
                {
                  \"id\": \"workbench.action.focusFifthEditorGroup\",
                  \"label\": \"Group &&5\",
                  \"enabled\": false
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.focusNextGroup\",
                  \"label\": \"&&Next Group\",
                  \"enabled\": false
                },
                {
                  \"id\": \"workbench.action.focusPreviousGroup\",
                  \"label\": \"&&Previous Group\",
                  \"enabled\": false
                },
                {
                  \"id\": \"vscode.menubar.separator\"
                },
                {
                  \"id\": \"workbench.action.focusLeftGroup\",
                  \"label\": \"Group &&Left\",
                  \"enabled\": false
                },
                {
                  \"id\": \"workbench.action.focusRightGroup\",
                  \"label\": \"Group &&Right\",
                  \"enabled\": false
                },
                {
                  \"id\": \"workbench.action.focusAboveGroup\",
                  \"label\": \"Group &&Above\",
                  \"enabled\": false
                },
                {
                  \"id\": \"workbench.action.focusBelowGroup\",
                  \"label\": \"Group &&Below\",
                  \"enabled\": false
                }
              ]
            }
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.quickOpen\",
            \"label\": \"Go to &&File...\"
          },
          {
            \"id\": \"workbench.action.showAllSymbols\",
            \"label\": \"Go to Symbol in &&Workspace...\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.gotoSymbol\",
            \"label\": \"Go to &&Symbol in Editor...\"
          },
          {
            \"id\": \"editor.action.revealDefinition\",
            \"label\": \"Go to &&Definition\"
          },
          {
            \"id\": \"editor.action.revealDeclaration\",
            \"label\": \"Go to &&Declaration\"
          },
          {
            \"id\": \"editor.action.goToTypeDefinition\",
            \"label\": \"Go to &&Type Definition\"
          },
          {
            \"id\": \"editor.action.goToImplementation\",
            \"label\": \"Go to &&Implementations\"
          },
          {
            \"id\": \"editor.action.goToReferences\",
            \"label\": \"Go to &&References\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.gotoLine\",
            \"label\": \"Go to &&Line/Column...\"
          },
          {
            \"id\": \"editor.action.jumpToBracket\",
            \"label\": \"Go to &&Bracket\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"editor.action.marker.nextInFiles\",
            \"label\": \"Next &&Problem\"
          },
          {
            \"id\": \"editor.action.marker.prevInFiles\",
            \"label\": \"Previous &&Problem\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"editor.action.dirtydiff.next\",
            \"label\": \"Next &&Change\"
          },
          {
            \"id\": \"editor.action.dirtydiff.previous\",
            \"label\": \"Previous &&Change\"
          }
        ]
      },
      \"Run\": {
        \"items\": [
          {
            \"id\": \"workbench.action.debug.start\",
            \"label\": \"&&Start Debugging\"
          },
          {
            \"id\": \"workbench.action.debug.run\",
            \"label\": \"Run &&Without Debugging\"
          },
          {
            \"id\": \"workbench.action.debug.stop\",
            \"label\": \"&&Stop Debugging\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.debug.restart\",
            \"label\": \"&&Restart Debugging\",
            \"enabled\": false
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.debug.configure\",
            \"label\": \"Open &&Configurations\"
          },
          {
            \"id\": \"debug.addConfiguration\",
            \"label\": \"A&&dd Configuration...\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.debug.stepOver\",
            \"label\": \"Step &&Over\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.debug.stepInto\",
            \"label\": \"Step &&Into\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.debug.stepOut\",
            \"label\": \"Step O&&ut\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.debug.continue\",
            \"label\": \"&&Continue\",
            \"enabled\": false
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"editor.debug.action.toggleBreakpoint\",
            \"label\": \"Toggle &&Breakpoint\"
          },
          {
            \"id\": \"\",
            \"label\": \"&&New Breakpoint\",
            \"submenu\": {
              \"items\": [
                {
                  \"id\": \"editor.debug.action.conditionalBreakpoint\",
                  \"label\": \"&&Conditional Breakpoint...\"
                },
                {
                  \"id\": \"editor.debug.action.toggleInlineBreakpoint\",
                  \"label\": \"Inline Breakp&&oint\"
                },
                {
                  \"id\": \"workbench.debug.viewlet.action.addFunctionBreakpointAction\",
                  \"label\": \"&&Function Breakpoint...\"
                },
                {
                  \"id\": \"editor.debug.action.addLogPoint\",
                  \"label\": \"&&Logpoint...\"
                }
              ]
            }
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.debug.viewlet.action.enableAllBreakpoints\",
            \"label\": \"&&Enable All Breakpoints\"
          },
          {
            \"id\": \"workbench.debug.viewlet.action.disableAllBreakpoints\",
            \"label\": \"Disable A&&ll Breakpoints\"
          },
          {
            \"id\": \"workbench.debug.viewlet.action.removeAllBreakpoints\",
            \"label\": \"Remove &&All Breakpoints\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"debug.installAdditionalDebuggers\",
            \"label\": \"&&Install Additional Debuggers...\"
          }
        ]
      },
      \"Terminal\": {
        \"items\": [
          {
            \"id\": \"workbench.action.terminal.new\",
            \"label\": \"&&New Terminal\"
          },
          {
            \"id\": \"workbench.action.terminal.split\",
            \"label\": \"&&Split Terminal\",
            \"enabled\": false
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.tasks.runTask\",
            \"label\": \"&&Run Task...\"
          },
          {
            \"id\": \"workbench.action.tasks.build\",
            \"label\": \"Run &&Build Task...\"
          },
          {
            \"id\": \"workbench.action.terminal.runActiveFile\",
            \"label\": \"Run &&Active File\"
          },
          {
            \"id\": \"workbench.action.terminal.runSelectedText\",
            \"label\": \"Run &&Selected Text\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.tasks.showTasks\",
            \"label\": \"Show Runnin&&g Tasks...\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.tasks.restartTask\",
            \"label\": \"R&&estart Running Task...\",
            \"enabled\": false
          },
          {
            \"id\": \"workbench.action.tasks.terminate\",
            \"label\": \"&&Terminate Task...\",
            \"enabled\": false
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.tasks.configureTaskRunner\",
            \"label\": \"&&Configure Tasks...\"
          },
          {
            \"id\": \"workbench.action.tasks.configureDefaultBuildTask\",
            \"label\": \"Configure De&&fault Build Task...\"
          }
        ]
      },
      \"Help\": {
        \"items\": [
          {
            \"id\": \"workbench.action.showWelcomePage\",
            \"label\": \"&&Welcome\"
          },
          {
            \"id\": \"workbench.action.showInteractivePlayground\",
            \"label\": \"I&&nteractive Playground\"
          },
          {
            \"id\": \"workbench.action.openDocumentationUrl\",
            \"label\": \"&&Documentation\"
          },
          {
            \"id\": \"update.showCurrentReleaseNotes\",
            \"label\": \"&&Release Notes\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.keybindingsReference\",
            \"label\": \"&&Keyboard Shortcuts Reference\"
          },
          {
            \"id\": \"workbench.action.openIntroductoryVideosUrl\",
            \"label\": \"Introductory &&Videos\"
          },
          {
            \"id\": \"workbench.action.openTipsAndTricksUrl\",
            \"label\": \"Tips and Tri&&cks\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.openTwitterUrl\",
            \"label\": \"&&Join Us on Twitter\"
          },
          {
            \"id\": \"workbench.action.openRequestFeatureUrl\",
            \"label\": \"&&Search Feature Requests\"
          },
          {
            \"id\": \"workbench.action.openIssueReporter\",
            \"label\": \"Report &&Issue\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.openLicenseUrl\",
            \"label\": \"View &&License\"
          },
          {
            \"id\": \"workbench.action.openPrivacyStatementUrl\",
            \"label\": \"Privac&&y Statement\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.toggleDevTools\",
            \"label\": \"&&Toggle Developer Tools\"
          },
          {
            \"id\": \"workbench.action.openProcessExplorer\",
            \"label\": \"Open &&Process Explorer\"
          },
          {
            \"id\": \"vscode.menubar.separator\"
          },
          {
            \"id\": \"workbench.action.showAboutDialog\",
            \"label\": \"&&About\"
          }
        ]
      }
    },
    \"keybindings\": {
      \"workbench.action.files.newUntitledFile\": {
        \"label\": \"Ctrl+N\",
        \"userSettingsLabel\": \"ctrl+n\"
      },
      \"workbench.action.newWindow\": {
        \"label\": \"Ctrl+Shift+N\",
        \"userSettingsLabel\": \"ctrl+shift+n\"
      },
      \"workbench.action.files.openFile\": {
        \"label\": \"Ctrl+O\",
        \"userSettingsLabel\": \"ctrl+o\"
      },
      \"workbench.action.files.openFolder\": {
        \"label\": \"Ctrl+K Ctrl+O\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+o\"
      },
      \"workbench.action.reopenClosedEditor\": {
        \"label\": \"Ctrl+Shift+T\",
        \"userSettingsLabel\": \"ctrl+shift+t\"
      },
      \"workbench.action.openRecent\": {
        \"label\": \"Ctrl+R\",
        \"userSettingsLabel\": \"ctrl+r\"
      },
      \"workbench.action.files.save\": {
        \"label\": \"Ctrl+S\",
        \"userSettingsLabel\": \"ctrl+s\"
      },
      \"workbench.action.files.saveAs\": {
        \"label\": \"Ctrl+Shift+S\",
        \"userSettingsLabel\": \"ctrl+shift+s\"
      },
      \"workbench.action.openSettings\": {
        \"label\": \"Ctrl+,\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+[Comma]\"
      },
      \"workbench.view.extensions\": {
        \"label\": \"Ctrl+Shift+X\",
        \"userSettingsLabel\": \"ctrl+shift+x\"
      },
      \"workbench.action.openGlobalKeybindings\": {
        \"label\": \"Ctrl+K Ctrl+S\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+s\"
      },
      \"workbench.extensions.action.showRecommendedKeymapExtensions\": {
        \"label\": \"Ctrl+K Ctrl+M\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+m\"
      },
      \"workbench.action.selectTheme\": {
        \"label\": \"Ctrl+K Ctrl+T\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+t\"
      },
      \"workbench.action.closeActiveEditor\": {
        \"label\": \"Ctrl+W\",
        \"userSettingsLabel\": \"ctrl+w\"
      },
      \"workbench.action.closeFolder\": {
        \"label\": \"Ctrl+K F\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k f\"
      },
      \"workbench.action.closeWindow\": {
        \"label\": \"Ctrl+W\",
        \"userSettingsLabel\": \"ctrl+w\"
      },
      \"workbench.action.quit\": {
        \"label\": \"Ctrl+Q\",
        \"userSettingsLabel\": \"ctrl+q\"
      },
      \"undo\": {
        \"label\": \"Ctrl+Z\",
        \"userSettingsLabel\": \"ctrl+z\"
      },
      \"redo\": {
        \"label\": \"Ctrl+Y\",
        \"userSettingsLabel\": \"ctrl+y\"
      },
      \"editor.action.clipboardCutAction\": {
        \"label\": \"Ctrl+X\",
        \"userSettingsLabel\": \"ctrl+x\"
      },
      \"editor.action.clipboardCopyAction\": {
        \"label\": \"Ctrl+C\",
        \"userSettingsLabel\": \"ctrl+c\"
      },
      \"editor.action.clipboardPasteAction\": {
        \"label\": \"Ctrl+V\",
        \"userSettingsLabel\": \"ctrl+v\"
      },
      \"actions.find\": {
        \"label\": \"Ctrl+F\",
        \"userSettingsLabel\": \"ctrl+f\"
      },
      \"editor.action.startFindReplaceAction\": {
        \"label\": \"Ctrl+H\",
        \"userSettingsLabel\": \"ctrl+h\"
      },
      \"workbench.action.findInFiles\": {
        \"label\": \"Ctrl+Shift+F\",
        \"userSettingsLabel\": \"ctrl+shift+f\"
      },
      \"workbench.action.replaceInFiles\": {
        \"label\": \"Ctrl+Shift+H\",
        \"userSettingsLabel\": \"ctrl+shift+h\"
      },
      \"editor.action.commentLine\": {
        \"label\": \"Ctrl+Shift+7\",
        \"userSettingsLabel\": \"ctrl+shift+7\"
      },
      \"editor.action.blockComment\": {
        \"label\": \"Ctrl+Shift+A\",
        \"userSettingsLabel\": \"ctrl+shift+a\"
      },
      \"editor.emmet.action.expandAbbreviation\": {
        \"label\": \"Tab\",
        \"userSettingsLabel\": \"tab\"
      },
      \"editor.action.selectAll\": {
        \"label\": \"Ctrl+A\",
        \"userSettingsLabel\": \"ctrl+a\"
      },
      \"editor.action.smartSelect.expand\": {
        \"label\": \"Shift+Alt+Right\",
        \"userSettingsLabel\": \"shift+alt+right\"
      },
      \"editor.action.smartSelect.shrink\": {
        \"label\": \"Shift+Alt+Left\",
        \"userSettingsLabel\": \"shift+alt+left\"
      },
      \"editor.action.copyLinesUpAction\": {
        \"label\": \"Ctrl+Shift+Alt+Up\",
        \"userSettingsLabel\": \"ctrl+shift+alt+up\"
      },
      \"editor.action.copyLinesDownAction\": {
        \"label\": \"Ctrl+Shift+Alt+Down\",
        \"userSettingsLabel\": \"ctrl+shift+alt+down\"
      },
      \"editor.action.moveLinesUpAction\": {
        \"label\": \"Alt+Up\",
        \"userSettingsLabel\": \"alt+up\"
      },
      \"editor.action.moveLinesDownAction\": {
        \"label\": \"Alt+Down\",
        \"userSettingsLabel\": \"alt+down\"
      },
      \"editor.action.insertCursorAbove\": {
        \"label\": \"Shift+Alt+Up\",
        \"userSettingsLabel\": \"shift+alt+up\"
      },
      \"editor.action.insertCursorBelow\": {
        \"label\": \"Shift+Alt+Down\",
        \"userSettingsLabel\": \"shift+alt+down\"
      },
      \"editor.action.insertCursorAtEndOfEachLineSelected\": {
        \"label\": \"Shift+Alt+I\",
        \"userSettingsLabel\": \"shift+alt+i\"
      },
      \"editor.action.addSelectionToNextFindMatch\": {
        \"label\": \"Ctrl+D\",
        \"userSettingsLabel\": \"ctrl+d\"
      },
      \"editor.action.selectHighlights\": {
        \"label\": \"Ctrl+Shift+L\",
        \"userSettingsLabel\": \"ctrl+shift+l\"
      },
      \"workbench.action.showCommands\": {
        \"label\": \"Ctrl+Shift+P\",
        \"userSettingsLabel\": \"ctrl+shift+p\"
      },
      \"workbench.action.toggleFullScreen\": {
        \"label\": \"F11\",
        \"userSettingsLabel\": \"f11\"
      },
      \"workbench.action.toggleZenMode\": {
        \"label\": \"Ctrl+K Z\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k z\"
      },
      \"workbench.action.toggleSidebarVisibility\": {
        \"label\": \"Ctrl+B\",
        \"userSettingsLabel\": \"ctrl+b\"
      },
      \"workbench.action.togglePanel\": {
        \"label\": \"Ctrl+J\",
        \"userSettingsLabel\": \"ctrl+j\"
      },
      \"workbench.action.zoomIn\": {
        \"label\": \"Ctrl+Shift+0\",
        \"userSettingsLabel\": \"ctrl+shift+0\"
      },
      \"workbench.action.zoomOut\": {
        \"label\": \"Ctrl+-\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+-\"
      },
      \"workbench.action.zoomReset\": {
        \"label\": \"Ctrl+NumPad0\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+numpad0\"
      },
      \"workbench.action.toggleEditorGroupLayout\": {
        \"label\": \"Shift+Alt+0\",
        \"userSettingsLabel\": \"shift+alt+0\"
      },
      \"workbench.view.explorer\": {
        \"label\": \"Ctrl+Shift+E\",
        \"userSettingsLabel\": \"ctrl+shift+e\"
      },
      \"workbench.view.search\": {
        \"label\": \"Ctrl+Shift+F\",
        \"userSettingsLabel\": \"ctrl+shift+f\"
      },
      \"workbench.view.scm\": {
        \"label\": \"Ctrl+Shift+G\",
        \"userSettingsLabel\": \"ctrl+shift+g\"
      },
      \"workbench.view.debug\": {
        \"label\": \"Ctrl+Shift+D\",
        \"userSettingsLabel\": \"ctrl+shift+d\"
      },
      \"workbench.action.output.toggleOutput\": {
        \"label\": \"Ctrl+K Ctrl+H\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+h\"
      },
      \"workbench.debug.action.toggleRepl\": {
        \"label\": \"Ctrl+Shift+Y\",
        \"userSettingsLabel\": \"ctrl+shift+y\"
      },
      \"workbench.action.terminal.toggleTerminal\": {
        \"label\": \"Ctrl+Shift+´\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+shift+[Equal]\"
      },
      \"workbench.actions.view.problems\": {
        \"label\": \"Ctrl+Shift+M\",
        \"userSettingsLabel\": \"ctrl+shift+m\"
      },
      \"editor.action.toggleWordWrap\": {
        \"label\": \"Alt+Z\",
        \"userSettingsLabel\": \"alt+z\"
      },
      \"workbench.action.navigateBack\": {
        \"label\": \"Ctrl+Alt+-\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+alt+-\"
      },
      \"workbench.action.navigateForward\": {
        \"label\": \"Ctrl+Shift+-\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+shift+-\"
      },
      \"workbench.action.navigateToLastEditLocation\": {
        \"label\": \"Ctrl+K Ctrl+Q\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+q\"
      },
      \"workbench.action.nextEditor\": {
        \"label\": \"Ctrl+PageDown\",
        \"userSettingsLabel\": \"ctrl+pagedown\"
      },
      \"workbench.action.previousEditor\": {
        \"label\": \"Ctrl+PageUp\",
        \"userSettingsLabel\": \"ctrl+pageup\"
      },
      \"workbench.action.nextEditorInGroup\": {
        \"label\": \"Ctrl+K Ctrl+PageDown\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+pagedown\"
      },
      \"workbench.action.previousEditorInGroup\": {
        \"label\": \"Ctrl+K Ctrl+PageUp\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+pageup\"
      },
      \"workbench.action.focusFirstEditorGroup\": {
        \"label\": \"Ctrl+1\",
        \"userSettingsLabel\": \"ctrl+1\"
      },
      \"workbench.action.focusSecondEditorGroup\": {
        \"label\": \"Ctrl+2\",
        \"userSettingsLabel\": \"ctrl+2\"
      },
      \"workbench.action.focusThirdEditorGroup\": {
        \"label\": \"Ctrl+3\",
        \"userSettingsLabel\": \"ctrl+3\"
      },
      \"workbench.action.focusFourthEditorGroup\": {
        \"label\": \"Ctrl+4\",
        \"userSettingsLabel\": \"ctrl+4\"
      },
      \"workbench.action.focusFifthEditorGroup\": {
        \"label\": \"Ctrl+5\",
        \"userSettingsLabel\": \"ctrl+5\"
      },
      \"workbench.action.focusLeftGroup\": {
        \"label\": \"Ctrl+K Ctrl+LeftArrow\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+left\"
      },
      \"workbench.action.focusRightGroup\": {
        \"label\": \"Ctrl+K Ctrl+RightArrow\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+right\"
      },
      \"workbench.action.focusAboveGroup\": {
        \"label\": \"Ctrl+K Ctrl+UpArrow\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+up\"
      },
      \"workbench.action.focusBelowGroup\": {
        \"label\": \"Ctrl+K Ctrl+DownArrow\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+down\"
      },
      \"workbench.action.quickOpen\": {
        \"label\": \"Ctrl+P\",
        \"userSettingsLabel\": \"ctrl+p\"
      },
      \"workbench.action.showAllSymbols\": {
        \"label\": \"Ctrl+T\",
        \"userSettingsLabel\": \"ctrl+t\"
      },
      \"workbench.action.gotoSymbol\": {
        \"label\": \"Ctrl+Shift+O\",
        \"userSettingsLabel\": \"ctrl+shift+o\"
      },
      \"editor.action.revealDefinition\": {
        \"label\": \"F12\",
        \"userSettingsLabel\": \"f12\"
      },
      \"editor.action.goToImplementation\": {
        \"label\": \"Ctrl+F12\",
        \"userSettingsLabel\": \"ctrl+f12\"
      },
      \"editor.action.goToReferences\": {
        \"label\": \"Shift+F12\",
        \"userSettingsLabel\": \"shift+f12\"
      },
      \"workbench.action.gotoLine\": {
        \"label\": \"Ctrl+G\",
        \"userSettingsLabel\": \"ctrl+g\"
      },
      \"editor.action.marker.nextInFiles\": {
        \"label\": \"F8\",
        \"userSettingsLabel\": \"f8\"
      },
      \"editor.action.marker.prevInFiles\": {
        \"label\": \"Shift+F8\",
        \"userSettingsLabel\": \"shift+f8\"
      },
      \"editor.action.dirtydiff.next\": {
        \"label\": \"Alt+F3\",
        \"userSettingsLabel\": \"alt+f3\"
      },
      \"editor.action.dirtydiff.previous\": {
        \"label\": \"Shift+Alt+F3\",
        \"userSettingsLabel\": \"shift+alt+f3\"
      },
      \"workbench.action.debug.start\": {
        \"label\": \"F5\",
        \"userSettingsLabel\": \"f5\"
      },
      \"workbench.action.debug.run\": {
        \"label\": \"Ctrl+F5\",
        \"userSettingsLabel\": \"ctrl+f5\"
      },
      \"workbench.action.debug.stop\": {
        \"label\": \"Shift+F5\",
        \"userSettingsLabel\": \"shift+f5\"
      },
      \"workbench.action.debug.restart\": {
        \"label\": \"Ctrl+Shift+F5\",
        \"userSettingsLabel\": \"ctrl+shift+f5\"
      },
      \"workbench.action.debug.stepOver\": {
        \"label\": \"F10\",
        \"userSettingsLabel\": \"f10\"
      },
      \"workbench.action.debug.stepInto\": {
        \"label\": \"F11\",
        \"userSettingsLabel\": \"f11\"
      },
      \"workbench.action.debug.stepOut\": {
        \"label\": \"Shift+F11\",
        \"userSettingsLabel\": \"shift+f11\"
      },
      \"workbench.action.debug.continue\": {
        \"label\": \"F5\",
        \"userSettingsLabel\": \"f5\"
      },
      \"editor.debug.action.toggleBreakpoint\": {
        \"label\": \"F9\",
        \"userSettingsLabel\": \"f9\"
      },
      \"editor.debug.action.toggleInlineBreakpoint\": {
        \"label\": \"Shift+F9\",
        \"userSettingsLabel\": \"shift+f9\"
      },
      \"workbench.action.terminal.split\": {
        \"label\": \"Ctrl+Shift+5\",
        \"userSettingsLabel\": \"ctrl+shift+5\"
      },
      \"workbench.action.tasks.build\": {
        \"label\": \"Ctrl+Shift+B\",
        \"userSettingsLabel\": \"ctrl+shift+b\"
      },
      \"workbench.action.keybindingsReference\": {
        \"label\": \"Ctrl+K Ctrl+R\",
        \"isNative\": false,
        \"userSettingsLabel\": \"ctrl+k ctrl+r\"
      },
      \"workbench.action.toggleDevTools\": {
        \"label\": \"Ctrl+Shift+I\",
        \"userSettingsLabel\": \"ctrl+shift+i\"
      }
    }
  },
  \"theme\": \"vs-dark\",
  \"themeBackground\": \"#1e1e1e\",
  \"pickerWorkingDir\": \"/home/$VM_USER/.vscode\",
  \"windowsState\": {
    \"lastActiveWindow\": {
      \"workspaceIdentifier\": {
        \"id\": \"d1b9a0d329ac9faccadc5afb54ee2eba\",
        \"configURIPath\": \"file:///home/$VM_USER/.vscode/KX.AS.CODE.code-workspace\"
      },
      \"backupPath\": \"/home/$VM_USER/.config/Code/Backups/d1b9a0d329ac9faccadc5afb54ee2eba\",
      \"uiState\": {
        \"mode\": 0,
        \"x\": 0,
        \"y\": 24,
        \"width\": 2198,
        \"height\": 1148
      }
    },
    \"openedWindows\": [

    ]
  }
}
EOF"

# Change the ownership to the $VM_USER user
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.config
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.vscode
