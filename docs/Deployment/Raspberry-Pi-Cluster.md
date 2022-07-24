# Raspberry Pi Cluster

This guide will detail how to deploy the images you built for the KX.AS.CODE Raspberry Pi cluster.

!!! danger "Important"
    This has only been tested on an 8GB Raspberry Pi 4B. It is not recommended to use anything less, as the resources will not be sufficient to run all the KX.AS.CODE services! Also note that one Raspberry Pi 4B will not be enough. In our testing, we have used four Raspberry Pi 4B boards setup in a 1 x KX-Main and 3 x KX-Workers configuration.

Hardware Pre-requisites

Here are the components we used in our test cluster.

- 1 x [Satix 19 inch rack wall mounting 2HE adjustable depth](https://www.amazon.de/gp/product/B07PL744NX/ref=ppx_yo_dt_b_asin_title_o05_s01?ie=UTF8&psc=1)
- 1 x [GeeekPi 1U Rack Kit for Raspberry Pi 4B, 19" 1U Rack Mount](https://www.amazon.de/gp/product/B0972928CN/ref=ppx_yo_dt_b_asin_title_o05_s02?ie=UTF8&psc=1)
- 1 x [DIGITUS Professional Extendible Shelf for 19-inch cabinets, Black](https://www.amazon.de/gp/product/B002KTE870/ref=ppx_yo_dt_b_asin_title_o03_s00?ie=UTF8&psc=1)
- 4 x [Raspberry Pi official power supply for Raspberry Pi 4 Model B, USB-C, 5.1V, 3A](https://www.amazon.de/gp/product/B07TMPC9FG/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&psc=1)
- 4 x [Raspberry Pi 4.8GB RAM](https://www.amazon.de/gp/product/B089LZ7KB8/ref=ppx_yo_dt_b_asin_title_o04_s00?ie=UTF8&psc=1)
- 4 x [SanDisk Extreme 64GB](https://www.amazon.de/gp/product/B07G3GMRYF/ref=ppx_yo_dt_b_asin_title_o05_s03?ie=UTF8&psc=1)
- 5 x [Samsung MZ-V7S500BW SSD 970 EVO Plus 500GB M.2 Internal NVMe SSD](https://www.amazon.de/gp/product/B07MFBLN7K/ref=ppx_yo_dt_b_asin_title_o05_s04?ie=UTF8&psc=1)
- 5 x [FIDECO M.2 NVME SATA SSD Enclosure, M.2 Enclosure USB 3.1 Gen 2](https://www.amazon.de/gp/product/B09WMYKDDW/ref=ppx_yo_dt_b_asin_title_o05_s04?ie=UTF8&psc=1)
- 4 x [CSL - Actiove USB Hub 3.2 Gen1 with Power Supply 4 Ports - Data hub](https://www.amazon.de/gp/product/B01E042UH2/ref=ppx_yo_dt_b_asin_title_o01_s00?ie=UTF8&psc=1)
- 4 x [DE CAT.8 Networking Cable](https://www.amazon.de/gp/product/B084C3GN6V/ref=ppx_yo_dt_b_asin_title_o02_s00?ie=UTF8&psc=1)
- 2 x [Surge protected extension leads](https://www.amazon.de/gp/product/B096FHSHVS/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1)

Here some photos from our first setup, including some of our learnings.

Most of the parts described above
![](../assets/images/Raspberry_PI_Setup_1.jpg){: .zoom}

!!! warning
    The Raspberry Pi does not have enough power to keep the NVME drive running. A powered hub is required. Either choose another type of drive, or like us, purchase a bunch of powered hubs, to manage it

![](../assets/images/Raspberry_PI_Setup_3.jpg){: .zoom}

Not on the list and not mandatory, but a nice touch is to add some luminous labels. :smile:
![](../assets/images/Raspberry_PI_Setup_4.jpg){: .zoom}

!!! info
    This guide is still a work in progress.