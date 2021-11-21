def extendedDescription

try {
    extendedDescription = "KX-Worker nodes are optional. On a local machine with lower amount of resources (equal to or below 16GB ram), a singe node standalone KX.AS.CODE deployment is advisable. In this case, just set the number of KX-Workers to 0. The 'allow workloads on master' toggle must be set to on in this case, else it will not be possible to deploy any workloads beyond the core tools and services. For VM hosts with higher available resources >16GB ram, feel free to install a full blown cluster and add some worker nodes!"
} catch(e) {
    println "Something went wrong in the GROOVY block (headlineKxWorkers): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <div class="divider-parameter-span"></div>
    <div id="headline-workers-div" style="display: block;">
    <h2>KX-Worker Parameters</h2>
    <span class="description-paragraph-span"><p>${extendedDescription}</p></span>
    </div>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (headlineKxWorkers): ${e}"
}

