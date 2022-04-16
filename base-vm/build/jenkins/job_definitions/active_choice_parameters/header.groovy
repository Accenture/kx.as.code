try {
    // language=HTML
    def HTML = """
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" />
    <link href="//cdn.muicss.com/mui-0.10.3/css/mui.min.css" rel="stylesheet" type="text/css"/>
    <link href="/userContent/css/kx-core.css" rel="stylesheet" type="text/css"/>
    
    <head>
    <script type="text/javascript" src="/userContent/javascript/kx-core.js"></script>
    </head>
    <body>
    <style scoped="scoped" onload="changeBuildButton();">   </style>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (header.groovy): ${e}"
}
