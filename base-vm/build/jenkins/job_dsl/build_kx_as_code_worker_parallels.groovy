import jenkins.model.Jenkins
import hudson.model.Item
import hudson.model.Items

def jobProperties
Item currentJob = Jenkins.instance.getItemByFullName('Parallels/GeneratedJobs/02_Build_KX.AS.CODE_Worker')
if (currentJob) {
  jobProperties = currentJob.@properties
}

jobProperties.each {
   println "${it.dump()}"
}

pipelineJob('Parallels/GeneratedJobs/02_Build_KX.AS.CODE_Worker') {
    definition {
      cps {
        script(readFileFromWorkspace('base-vm/build/jenkins/pipelines/build-kx.as.code-worker-parallels.Jenkinsfile'))
        sandbox()
      }
      queue("Parallels/GeneratedJobs/02_Build_KX.AS.CODE_Worker")
      if (jobProperties) {
      configure { root ->
        def properties = root / 'properties'
        jobProperties.each { property ->
          String xml = Items.XSTREAM2.toXML(property)
          def jobPropertiesPropertyNode = new XmlParser().parseText(xml)
          properties << jobPropertiesPropertyNode
        }
      }
    }
  }
}