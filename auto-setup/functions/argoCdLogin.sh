argoCdLogin() {

    # Login to ArgoCD
    for i in {1..10}; do
        response=$(argocd login grpc.argocd.${baseDomain} --username admin --password ${vmPassword} --insecure)
        if [[ $response =~ "successfully" ]]; then
            echo "Logged in OK. Exiting loop"
            break
        fi
        sleep 15
    done

}