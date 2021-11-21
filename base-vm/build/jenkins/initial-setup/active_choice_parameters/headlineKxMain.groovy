def extendedDescription

try {
    extendedDescription = "KX-Main nodes provide two core functions - Kubernetes master services as well as the desktop environment for easy access to deployed tools and documentation. Only the first KX-Main node hosts both the desktop environment, and the Kubernetes Master services. Subsequent KX-Main nodes host the Kubernetes Master services only. In a physical environment with 16GB ram or less, it is recommended to leave at least 4-6GB ram to the host operating system, leaving 10-12GB that can be allocated to KX-Main. In this scenario, it is recommended to set KX-Worker nodes to zero, and run the whole KX.AS.CODE setup in standalone mode."
} catch(e) {
    println "Something went wrong in the GROOVY block (headlineKxMain): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <div class="divider-parameter-span"></div>
    <div id="headline-main-div" style="display: block;">
    <h2>KX-Main Parameters</h2>
    <span class="description-paragraph-span"><p>${extendedDescription }</p></span>
    </div>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (headlineKxMain): ${e}"
}

