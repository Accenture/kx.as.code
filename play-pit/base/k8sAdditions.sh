#!/bin/bash -x
set -euo pipefail

. /etc/environment
export VM_USER=$VM_USER

KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

# Loop around the non verbose health check a few times until Kubernetes is healthy
wait-for-health-ok() {
        timeout -s TERM 600 bash -c \
        'while [[ "$(curl -s -k https://localhost:6443/livez)" != "ok" ]];\
        do sleep 5;\
        done' ${1}
}
wait-for-health-ok https://localhost:6443/livez

# Output full health check report again after loop ended with "ok"
curl -s -k https://localhost:6443/livez?verbose

# List all deployed services
kubectl get all --all-namespaces

# Install Self-Signing TLS Certificate Manager
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.0/cert-manager.yaml

# Check whether cert-manager-webhook is ready
kubectl rollout status deployment cert-manager-webhook -n cert-manager || true

# Create Cert Manager Self Signing Issuer
cat << EOF > $KUBEDIR/certificate-issuer.yaml
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF
kubectl apply -f $KUBEDIR/certificate-issuer.yaml || true

# Make Kubernetes Dashboard Available via Domain Name "k8s-dashboard.kx-as-code.local"
cat << EOF > $KUBEDIR/dashboard-ingress.yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: kubernetes-dashboard-ingress
  annotations:
     kubernetes.io/ingress.class: "nginx"
     nginx.ingress.kubernetes.io/ssl-passthrough: "true"
     nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  tls:
  - hosts:
    - k8s-dashboard.kx-as-code.local
  rules:
  - host: k8s-dashboard.kx-as-code.local
    http:
      paths:
       - path: /
         backend:
           serviceName: kubernetes-dashboard
           servicePort: 443
EOF
kubectl apply -f $KUBEDIR/dashboard-ingress.yaml -n kubernetes-dashboard

# List all deployed services
kubectl get all --all-namespaces

# Import KX.AS.CODE Wildcard Certificate into Kubernetes
kubectl create secret generic kx.as.code-wildcard-cert --from-file=/home/$VM_USER/Kubernetes/kx-certs

# Check Self-Signed TLS certificate is valid
sudo mkdir -p $KUBEDIR/certs
sudo chown -R $VM_USER:$VM_USER $KUBEDIR
kubectl get secret kx.as.code-wildcard-cert -o jsonpath="{.data.tls\.crt}" | base64 -d > $KUBEDIR/certs/tls.crt
kubectl get secret kx.as.code-wildcard-cert -o jsonpath="{.data.tls\.key}" | base64 -d > $KUBEDIR/certs/tls.key
kubectl get secret kx.as.code-wildcard-cert -o jsonpath="{.data.ca\.crt}" | base64 -d > $KUBEDIR/certs/ca.crt
sudo -H -i -u $VM_USER sh -c "openssl x509 -in $KUBEDIR/certs/tls.crt -text -noout"

# Create Secret for Kubernetes Dashboard Certificates
kubectl delete secret kubernetes-dashboard-certs -n kubernetes-dashboard
kubectl create secret generic kubernetes-dashboard-certs --from-file=$KUBEDIR/certs -n kubernetes-dashboard

# Update Kubernetes Dashboard with new certificate
disableSessionTimeout=$($KUBEDIR/vagrant.json | jq -r '.config.disableSessionTimeout')
if [[ "disableSessionTimeout" == "true" ]]; then
    sed -i '/^ *args:/,/^ *[^:]*:/s/^.*- --auto-generate-certificates/            - --tls-cert-file=\/tls.crt\n            - --tls-key-file=\/tls.key\n            - --token-ttl=0\n            #- --auto-generate-certificates/' $KUBEDIR/dashboard.yaml
else
    sed -i '/^ *args:/,/^ *[^:]*:/s/^.*- --auto-generate-certificates/            - --tls-cert-file=\/tls.crt\n            - --tls-key-file=\/tls.key\n            #- --auto-generate-certificates/' $KUBEDIR/dashboard.yaml
fi
kubectl apply -f $KUBEDIR/dashboard.yaml -n kubernetes-dashboard

# Add Nginx Controller Helm Repository
sudo -H -i -u $VM_USER sh -c "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx"
sudo -H -i -u $VM_USER sh -c "helm repo update"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install Nginx Ingress controller
helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx --install --namespace kube-system --set rbac.create=true --set "controller.extraArgs.default-ssl-certificate=default/kx.as.code-wildcard-cert" --set "controller.extraArgs.enable-ssl-passthrough=" --set controller.hostNetwork=true --set "controller.extraArgs.report-node-internal-ip-address="

# Update Wildcard DNS entry for kx-as-code.local
NGINX_INGRESS_IP=$(kubectl get svc nginx-ingress-ingress-nginx-controller -n kube-system -o jsonpath={.spec.clusterIP})
echo "address=/.kx-as-code.local/$NGINX_INGRESS_IP" | sudo tee -a /etc/dnsmasq.d/kx-as-code.local.conf
sudo systemctl restart dnsmasq

gui-status-output "# Waiting for K8s Dashboard"
# Test to see if the Kubernetes Cluster is up and notify when done
wait-for-url() {
    timeout -s TERM 600 bash -c \
        'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${0})" != "200" ]];\
  do sleep 5;\
  done' ${1}
}
wait-for-url https://k8s-dashboard.kx-as-code.local

# Put Kubernetes Dashboard Icon on Desktop
cat << EOF > /home/$VM_USER/Desktop/Kubernetes-Dashboard.desktop
[Desktop Entry]
Version=1.0
Name=Kubernetes Dashboard
GenericName=Kubernetes Dashboard
Comment=Kubernetes Dashboard
Exec=/usr/bin/google-chrome-stable %U https://k8s-dashboard.kx-as-code.local --use-gl=angle --password-store=basic --incognito
StartupNotify=true
Terminal=false
Icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/kubernetes.png
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Put Shortcut to get K8s Admin Token on Desktop
cat << EOF > /home/$VM_USER/Desktop/Get-Kubernetes-Token.desktop
[Desktop Entry]
Version=1.0
Name=Get Kubernetes Token
GenericName=Get Kubernetes Token
Comment=Get Kubernetes Token
Exec=tilix --command /home/kx.hero/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/getK8sClusterAdminToken.sh
StartupNotify=true
Terminal=true
Icon=utilities-terminal
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 /home/$VM_USER/Desktop/*.desktop
chown $VM_USER:$VM_USER /home/$VM_USER/Desktop/*.desktop

# Add check for every login telling user if K8s is ready or not
sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.config/autostart"
cat << EOF > /home/$VM_USER/.config/autostart/check-k8s.desktop
[Desktop Entry]
Type=Application
Name=K8s-Startup-Status
Exec=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/checkK8sStartup.sh
EOF
chmod 755 /home/$VM_USER/.config/autostart/check-k8s.desktop
chown $VM_USER:$VM_USER /home/$VM_USER/.config/autostart/check-k8s.desktop

EXECUTION_END=$(date +"%s")
TIME_DIFFERENCE=$((EXECUTION_END - EXECUTION_START))

# Add notification to desktop to notify that K8s intialization is completed
export LOGGED_IN_USER=$(who | cut -d' ' -f1 | sort | uniq | grep $VM_USER)
if [[ -z $LOGGED_IN_USER ]]; then
    # If kx.hero user is not yet logged in, then add notification to be launched when user logs in
    sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.config/autostart"
    echo """
   [Desktop Entry]
   Type=Application
   Name=Show-K8s-Init-Progress
   Exec=sudo -u $VM_USER bash -c \"DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 'KX.AS.CODE Notification' 'Base Kubernetes cluster intialization completed. K8s initialization took '$((TIME_DIFFERENCE / 60))' minutes and '$((TIME_DIFFERENCE % 60))' seconds' --icon=dialog-information && rm -f /home/$VM_USER/.config/autostart/notify-k8s-init-comnpleted.desktop\"
   """ | sudo -u $VM_USER tee /home/$VM_USER/.config/autostart/notify-k8s-init-comnpleted.desktop
else
    # Add notification to desktop to notify that K8s intialization has started
    sudo -u $VM_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 "KX.AS.CODE Notification" "Base Kubernetes cluster intialization completed. K8s initialization took $((TIME_DIFFERENCE / 60)) minutes and $((TIME_DIFFERENCE % 60)) seconds"  --icon=dialog-information
fi

# Make Desktop Icons Available in Application Menu
sudo cp /home/$VM_USER/Desktop/*.desktop /usr/share/applications
