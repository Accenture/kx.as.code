def extendedDescription

try {
    extendedDescription = "There are two types of storage provisioned into KX.AS.CODE. One is a slower network storage based on GlusterFS and the second is local storage. Both are made available internally to the Kubernetes cluster via storage classes. There are advantages and disadvantages of each. Glusterfs is slower, but ensures the workload remains portable. Local storage is faster, but means a workload is tied to a host. The faster local storage is recommended for database servers."
} catch(e) {
    println "Something went wrong in the GROOVY block (headlineStoragePrameters): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <div id="headline-storage-div" style="display: none;">
    <h2>Storage Parameters</h2>
    <span class="description-paragraph-span"><p>${extendedDescription}</p></span>
    </div>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (headlineStoragePrameters): ${e}"
}
