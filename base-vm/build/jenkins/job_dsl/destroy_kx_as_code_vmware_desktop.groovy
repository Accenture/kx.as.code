import jenkins.model.Jenkins
import hudson.model.Item
import hudson.model.Items

def jobProperties
Item currentJob = Jenkins.instance.getItemByFullName('VirtualBox/GeneratedJobs/05_Destroy_KX.AS.CODE')
if (currentJob) {
  jobProperties = currentJob.@properties
}

jobProperties.each {
   println "${it.dump()}"
}

pipelineJob('VirtualBox/GeneratedJobs/05_Destroy_KX.AS.CODE') {
    definition {
      cps {
        script(readFileFromWorkspace('base-vm/build/jenkins/pipelines/destroy-kx.as.code-vmware-desktop.Jenkinsfile'))
        sandbox()
      }
      queue("VirtualBox/GeneratedJobs/05_Destroy_KX.AS.CODE")
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