document.querySelectorAll('.zoom').forEach(item => {
    item.addEventListener('click', function () {
        this.classList.toggle('image-zoom-large');
    })
});

document.querySelectorAll('.zoom-table').forEach(item => {
    item.addEventListener('click', function () {
        this.classList.toggle('image-zoom-large-table');
    })
});

let slideIndex = 1;
showSlides(slideIndex, "gopass");
showSlides(slideIndex, "keycloak");
showSlides(slideIndex, "openlens");
showSlides(slideIndex, "lam");
showSlides(slideIndex, "rabbitmq");
showSlides(slideIndex, "pgadmin");
showSlides(slideIndex, "kubernetes-dashboard");
showSlides(slideIndex, "argocd");
showSlides(slideIndex, "neuvector");
showSlides(slideIndex, "elasticsearch");
showSlides(slideIndex, "filebeat");
showSlides(slideIndex, "heartbeat");
showSlides(slideIndex, "kibana");
showSlides(slideIndex, "metricbeat");
showSlides(slideIndex, "gitea");
showSlides(slideIndex, "gitlab");
showSlides(slideIndex, "grafana");
showSlides(slideIndex, "grafana-loki");
showSlides(slideIndex, "graphite");
showSlides(slideIndex, "harbor");
showSlides(slideIndex, "consul");
showSlides(slideIndex, "vault");
showSlides(slideIndex, "jenkins");
showSlides(slideIndex, "artifactory");
showSlides(slideIndex, "mattermost");
showSlides(slideIndex, "minio-s3");
showSlides(slideIndex, "nextcloud");
showSlides(slideIndex, "nexus3");
showSlides(slideIndex, "prometheus");
showSlides(slideIndex, "rocketchat");
showSlides(slideIndex, "selenium4");
showSlides(slideIndex, "sonarqube");
showSlides(slideIndex, "sysdig-falco");
showSlides(slideIndex, "teamcity");
showSlides(slideIndex, "influxdb2");
showSlides(slideIndex, "telegraf");
showSlides(slideIndex, "telegraf-ds");

// Next/previous controls
function plusSlides(n, sliderGroup) {
    showSlides(slideIndex += n, sliderGroup);
}

// Thumbnail image controls
function currentSlide(n,sliderGroup) {
    showSlides(slideIndex = n, sliderGroup);
}

function showSlides(n, sliderGroup) {
    let i;
    let slides = document.getElementsByClassName(sliderGroup + "Image");
    let dots = document.getElementsByClassName(sliderGroup + "Dot");
    console.log(sliderGroup);
    console.log(slides);
    console.log(dots);
    if (n > slides.length) {slideIndex = 1}
    if (n < 1) {slideIndex = slides.length}
    for (i = 0; i < slides.length; i++) {
        slides[i].style.display = "none";
    }
    for (i = 0; i < dots.length; i++) {
        dots[i].className = dots[i].className.replace(" active", "");
    }
    slides[slideIndex-1].style.display = "block";
    dots[slideIndex-1].className += " active";
}