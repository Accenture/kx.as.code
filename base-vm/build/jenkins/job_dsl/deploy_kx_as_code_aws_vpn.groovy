import jenkins.model.Jenkins
import hudson.model.Item
import hudson.model.Items

def jobProperties
Item currentJob = Jenkins.instance.getItemByFullName('AWS/GeneratedJobs/03_Run_KX.AS.CODE (VPN)')
if (currentJob) {
  jobProperties = currentJob.@properties
}

jobProperties.each {
   println "${it.dump()}"
}

pipelineJob('AWS/GeneratedJobs/03_Run_KX.AS.CODE (VPN)') {
    definition {
      cps {
        script(readFileFromWorkspace('base-vm/build/jenkins/pipelines/deploy-kx.as.code-aws-vpn.Jenkinsfile'))
        sandbox()
      }
      queue("AWS/GeneratedJobs/03_Run_KX.AS.CODE (VPN)")
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
