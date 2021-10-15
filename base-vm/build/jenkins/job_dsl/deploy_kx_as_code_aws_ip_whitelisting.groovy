import jenkins.model.Jenkins
import hudson.model.Item
import hudson.model.Items

def jobProperties
Item currentJob = Jenkins.instance.getItemByFullName('AWS/GeneratedJobs/04_Run_KX.AS.CODE (IP Whitelisting)')
if (currentJob) {
  jobProperties = currentJob.@properties
}

jobProperties.each {
   println "${it.dump()}"
}

pipelineJob('AWS/GeneratedJobs/04_Run_KX.AS.CODE (IP Whitelisting)') {
    definition {
      cps {
        script(readFileFromWorkspace('base-vm/build/jenkins/pipelines/deploy-kx.as.code-aws-ip-whitelisting.Jenkinsfile'))
        sandbox()
      }
      queue("AWS/GeneratedJobs/04_Run_KX.AS.CODE (IP Whitelisting)")
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
