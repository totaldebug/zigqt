<a name="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/totaldebug/zigqt">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Zigqt</h3>

  <p align="center">
    An alpine overlay to create a zigbee2mqtt hub on a Raspberry Pi
    <br />
    <a href="https://totaldebug.uk/posts/zigqt-zigbee2mqtt-pi-hub/"><strong>Explore the article »</strong></a>
    <br />
    <br />
    <a href="https://github.com/totaldebug/zigqt/issues">Report Bug</a>
    ·
    <a href="https://github.com/totaldebug/zigqt/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#additional-configuration">Additional Configuration</a></li>
        <li><a href="#further-customisation">Further Customisation</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

This project was created after moving my Home Assistant install to a virtual machine, my server lives too far away for the zigbee dongle to reach, I wanted a small hub that I could plug-in and run zigbee2mqtt. I also wanted it to be low maintenance hence using Alpine and overlays, this way the OS runs diskless with a persistent disk for configuration, if it stops working, reboot and it will be back in the original state meaning less messing about when things go wrong.

Here we provide an overlay with all the necessary configuration to get you up and running, below are the main features:

* Support for DHCP unlike some other Pi Alpine overlays.
* Basic ssh server to log-into from another computer.
* mDNS record `zigqt.local` to easily connect.
* Installs zigbee2mqtt and enables web interface
* Add additional configuration based on samples to root without need to re-package overlay

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

This section should list any major frameworks/libraries used to bootstrap your project. Leave any add-ons/plugins for the acknowledgements section. Here are a few examples.

* [![Apline][Alpine]][Alpine-url]
* [![RaspberryPi][RaspberryPi]][RaspberryPi-url]
* [![PiPOEHat][PiPOEHat]][PiPOEHat-url]
* [![zigbee2mqtt][zigbee2mqtt]][zigbee2mqtt-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

I recommend following this article [Creating a standalone zigbee2mqtt hub using Alpine Linux](https://totaldebug.uk), which includes downloading & creating installation media as well as applying this custom overlay. Tools provided here can be used on any platform for any install modes (diskless, data disk, system disk).

### Prerequisites

* A RaspberryPi (recommend 3b+ or higher)
* Zigbee dongle (I use Conbee II)
* Micro SD Card
* Micro SD Card reader

The SD Card needs to be formatted into two partitions:

1. Boot Partition (512M Min Recommended)
2. Persistent Storage Partition (rest of the storage)

### Installation

Just add [**zzigqt.apkovl.tar.gz**]() overlay file to the root of Alpine Linux boot media and boot the system.

By default the image will get a DHCP Address assigned, `/var`, `/etc/shaddow` and `/etc/zigbee2mqtt` will be mapped to persistent storage.

Connect via SSH or HTTP using:
```bash
ssh root@zigqt.local
http://zigqt.local:8080
```

As with Alpine Linux, initial boot, `root` account has no password (change this after setup).

Main execution steps are logged in `/var/log/messages`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Additional Configuration

Add-on files may be added next to `zigqt.apkovl.tar.gz` to customise setup (sample files are provided):
- `interfaces` (*optional*): define network interfaces at will, if defaults DCHP-based are not suitable.
- `wpa_supplicant.conf` (*mandatory for wifi use*): define wifi SSID & password.
- `configuration.yaml` (*optional*): define configuration for zigbee2mqtt, a default configuration will be applied if not provided.
- `secret.yaml` (*optional*): define secrets for zigbee2mqtt, random will be generated on first boot if this is not provided.
- `unattended.sh` (*optional*): make custom automated deployment script to further tune & extend setup (backgrounded).

*Note:* these files are linux text files: Windows/macOS users need to use text editors supporting linux text line-ending (such as [notepad++](https://notepad-plus-plus.org/) or VSCode).

**Goody:** seamless USB bootstrapping for PiZero devices (or similar which can support USB ethernet gadget networking):\
Just add `dtoverlay=dwc2` in `usercfg.txt` (or `config.txt`), and plug-in USB to Computer port.
With Computer set-up to share networking with USB interface as 10.42.0.1 gateway, one can log into device from Computer with `ssh root@10.42.0.2` !...

### Further customisation

This repository may be forked/cloned/downloaded.
Main script file is [`headless.sh`](https://github.com/totaldebug/zigqt/blob/main/zigqt/usr/local/bin/headless.sh).
Execute `./make.sh` to rebuild `zigqt.apkovl.tar.gz`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

- [x] Add Issue templates
- [x] Add Releases
- [x] Add DHCP
- [x] Add WiFi
- [x] Add mDNS
- [x] Persistent Zigbee2mqtt configuration

See the [open issues](https://github.com/totaldebug/zigqt/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Sponsors

My projects arent possible without the support of the community, please consider donating a small amount to keep these projects alive.

[![Sponsor][Sponsor]][Sponsor-url]

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "type/feature".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

[Discord](https://discord.gg/6fmekudc8Q)
[Discussions](https://github.com/totaldebug/zigqt/discussions)

Project Link: [https://github.com/totaldebug/zigqt](https://github.com/totaldebug/zigqt)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Below are a list of resources that I used to assist with this project.

* [Alpine Linux Headless Bootstrap](https://github.com/macmpi/alpine-linux-headless-bootstrap)
* [Alpine Linux on Raspberry Pi 4 Headless](https://alldrops.info/posts/linux-drops/2021-06-21_alpine-linux-on-raspberry-pi-4-headless-persistent-install/)


<p align="right">(<a href="#readme-top">back to top</a>)</p>




<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/totaldebug/zigqt.svg?style=for-the-badge
[contributors-url]: https://github.com/totaldebug/zigqt/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/totaldebug/zigqt.svg?style=for-the-badge
[forks-url]: https://github.com/totaldebug/zigqt/network/members
[stars-shield]: https://img.shields.io/github/stars/totaldebug/zigqt.svg?style=for-the-badge
[stars-url]: https://github.com/totaldebug/zigqt/stargazers
[issues-shield]: https://img.shields.io/github/issues/totaldebug/zigqt.svg?style=for-the-badge
[issues-url]: https://github.com/totaldebug/zigqt/issues
[license-shield]: https://img.shields.io/github/license/totaldebug/zigqt.svg?style=for-the-badge
[license-url]: https://github.com/totaldebug/zigqt/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/marksie1988
[Sponsor]: https://img.shields.io/badge/sponsor-000?style=for-the-badge&logo=githubsponsors&logoColor=red
[Sponsor-url]: https://github.com/sponsors/marksie1988

[Alpine]: https://img.shields.io/badge/AlpineLinux-fff?style=for-the-badge&logo=alpinelinux&logoColor=blue
[Alpine-url]: https://www.alpinelinux.org/
[RaspberryPi]: https://img.shields.io/badge/RaspberryPi-fff?style=for-the-badge&logo=raspberrypi&logoColor=red
[RaspberryPi-url]: https://www.raspberrypi.com/
[PiPOEHat]: https://img.shields.io/badge/poe+hat-000?style=for-the-badge&logo=raspberrypi&logoColor=red
[PiPOEHat-url]: https://www.raspberrypi.com/products/poe-plus-hat/
[zigbee2mqtt]: https://img.shields.io/badge/zigbee2mqtt-000?style=for-the-badge&logo=zigbee&logoColor=white
[zigbee2mqtt-url]: https://www.zigbee2mqtt.io/
