# Docker Airbase Environment (LAMP)
A dockerized LAMP environment for developing PHP applications


## Setup and usage
### Install everything that's necessary
This project use Docker to create containers. Therefore, you obviously need that on your machine.
<br>
You can install Docker through Homebrew by running the following installation command:
```bash
brew cask install docker
```
If you don't have Homebrew installed, get it by running:
```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)
```
<br><br>
This project also depends on Make which you can install:
```bash
brew install make
```
Last you will need to deactivate your local dnsmasq:
```bash
sudo brew services stop dnsmasq
```
