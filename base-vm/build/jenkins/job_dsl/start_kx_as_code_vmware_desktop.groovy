import jenkins.model.Jenkins
import hudson.model.Item
import hudson.model.Items

def jobProperties
Item currentJob = Jenkins.instance.getItemByFullName('VMWare_Workstation/GeneratedJobs/03_Start_KX.AS.CODE')
if (currentJob) {
  jobProperties = currentJob.@properties
}

jobProperties.each {
   println "${it.dump()}"
}

pipelineJob('VMWare_Workstation/GeneratedJobs/03_Start_KX.AS.CODE') {
    definition {
      cps {
        script(readFileFromWorkspace('base-vm/build/jenkins/pipelines/start-kx.as.code-vmware-desktop.Jenkinsfile'))
        sandbox()
      }
      queue("VMWare_Workstation/GeneratedJobs/03_Start_KX.AS.CODE")
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