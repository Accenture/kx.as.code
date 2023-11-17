import jenkins.model.Jenkins
import hudson.model.Item
import hudson.model.Items

def jobProperties
Item currentJob = Jenkins.instance.getItemByFullName('Actions/AWS/GeneratedJobs/Build_KX.AS.CODE_Node')
if (currentJob) {
  jobProperties = currentJob.@properties
}

jobProperties.each {
   println "${it.dump()}"
}

pipelineJob('Actions/AWS/GeneratedJobs/Build_KX.AS.CODE_Node') {
    definition {
      cps {
        script(readFileFromWorkspace('base-vm/build/jenkins/job_definitions/declarative_pipelines/kx.as.code-image-builder-node-aws-ami.Jenkinsfile'))
        sandbox()
      }
      queue("Actions/AWS/GeneratedJobs/Build_KX.AS.CODE_Node")
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