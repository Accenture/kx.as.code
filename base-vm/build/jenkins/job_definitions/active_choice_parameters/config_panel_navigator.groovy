try {
    // language=HTML
    def HTML = """
    <body xmlns="http://www.w3.org/1999/html">
        <div id="config-panel-loading-progress-status-overlay"></div>
        <div id="config-panel-outer-div" class="config-outer-wrapper">
            <div class="config-inner-panel">
                <div id="config-navigator" class="config-selector-panel">
                    <div class="config-tab-selected" id="config-panel-profile-selection" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/format-list-checks.svg" id="config-panel-profile-selection-icon" class="config-panel-icon svg-blue" alt="Profile Selection"></div>
                    <div class="config-tab" id="config-panel-general-params" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/form-textbox.svg" id="config-panel-general-params-icon" class="config-panel-icon svg-white" alt="General Parameters"></div>
                    <div class="config-tab" id="config-panel-kx-main-config" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/memory.svg" id="config-panel-kx-main-config-icon" class="config-panel-icon svg-white" alt="KX-Main Node Configuration"></div>
                    <div class="config-tab" id="config-panel-storage-config" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/harddisk.svg" id="config-panel-storage-config-icon" class="config-panel-icon svg-white" alt="Storage Configuration"></div>
                    <div class="config-tab" id="config-panel-template-selection" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/apps.svg" id="config-panel-template-selection-icon" class="config-panel-icon svg-white" alt="Application Template Group Selection"></div>
                    <div class="config-tab" id="config-panel-user-provisioning" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/account-multiple.svg" id="config-panel-user-provisioning-icon" class="config-panel-icon svg-white" alt="User Provisioning"></div>
                    <div class="config-tab" id="config-panel-kx-summary-start" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/clipboard-text-play-outline.svg" id="config-panel-kx-summary-start-icon" class="config-panel-icon svg-white" alt="Deployment"></div>
                </div>
                <div id="config-placeholder" class="config-placeholder">
                    <div id="grid-spinner" class="grid-spinner-wrapper">
                        <div class="sk-grid">
                          <div class="sk-grid-cube"></div>
                          <div class="sk-grid-cube"></div>
                          <div class="sk-grid-cube"></div>
                          <div class="sk-grid-cube"></div>
                          <div class="sk-grid-cube"></div>
                          <div class="sk-grid-cube"></div>
                          <div class="sk-grid-cube"></div>
                          <div class="sk-grid-cube"></div>
                          <div class="sk-grid-cube"></div>
                        </div>
                    </div>
                </div>
                <div id="config-navigator-footer" class="config-selector-footer">
                    <div class="config-tab-footer-icons" id="config-panel-footer-left-nav-div" onclick="" style="display: block"><img src="/userContent/icons/chevron-left.svg" id="config-panel-left-nav-icon" class="config-tab-footer-icons svg-white" alt="navigate previous"></div>
                    <div class="config-tab-footer-icons" id="config-panel-footer-right-nav-div" onclick="" style="display: block"><img src="/userContent/icons/chevron-right.svg" id="config-panel-right-nav-icon" class="config-tab-footer-icons svg-white" alt="navigate next"></div>
                </div>
            </div>
        </div>
        <style scoped="scoped" onload="loadFirstConfigPanel();">   </style>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (config_panel_navigator.groovy): ${e}"
}
