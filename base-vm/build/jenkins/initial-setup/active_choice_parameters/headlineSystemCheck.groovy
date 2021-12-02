def extendedDescription

try {
    extendedDescription = "The charts below show how the selections you made above fit in line with the resources available on your system. If any of the charts are red, you should look to make corrections above. For the storage parameters, this is not critical, as the volumes are thinly provisioned anyway, so an overallocation is not a problem, as long as you don't intend to use the full space."
} catch(e) {
    println "Something went wrong in the GROOVY block (headlineSystemCheck): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <div id="header-system-check-div" style="display: none;">
        <h2>System Check</h2>
        <span class="description-paragraph-span"><p>${extendedDescription}</p></span>
    </div>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (headlineSystemCheck): ${e}"
}
