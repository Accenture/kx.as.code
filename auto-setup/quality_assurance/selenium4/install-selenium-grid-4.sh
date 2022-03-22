#!/bin/bash

# Clone the project
/usr/bin/sudo rm -rf ${installationWorkspace}/docker-selenium
git clone -b ${gitTag} --single-branch https://github.com/seleniumhq/docker-selenium.git ${installationWorkspace}/docker-selenium

# Determine whether a values_template.yaml file exists for the solution and use it if so - and replace mustache variables such as url etc
if [[ -f ${installComponentDirectory}/values_template.yaml ]]; then
    envhandlebars <${installComponentDirectory}/values_template.yaml >${installationWorkspace}/${componentName}_values.yaml
    valuesFileOption="-f ${installationWorkspace}/${componentName}_values.yaml"
else
    # Set to blank to avoid variable unbound error
    valuesFileOption=""
fi

# Install full grid (Router, Distributor, EventBus, SessionMap and SessionQueue components separated)
helm upgrade --install ${valuesFileOption} ${componentName} --namespace ${namespace} ${installationWorkspace}/docker-selenium/chart/selenium-grid/.

# Generate ingress resource file
echo """
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${namespace}-${componentName}
  namespace: ${namespace}
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  tls:
    - hosts:
        - ${componentName}.${baseDomain}
  rules:
    - host: ${componentName}.${baseDomain}
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: selenium-hub
                port:
                  number: 4444
""" | /usr/bin/sudo tee ${installationWorkspace}/${componentName}_ingress.yaml

# Create ingress resource
/usr/bin/sudo kubectl apply -f ${installationWorkspace}/${componentName}_ingress.yaml -n ${namespace}