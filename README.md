# Docker Airbase Environment (LAMP)
A dockerized LAMP environment for developing PHP applications.

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
<br>
This project also depends on Make. We're using make targets in order to spin up the containers and for deploying new repositories to the LAMP environment. Install Make by:
```bash
brew install make
```
Last you will need to deactivate your local dnsmasq:
```bash
sudo brew services stop dnsmasq
```
<br><br>

### Configure the .env file and Makefile
In the .env file, you're able to control different variables such as choosing the desired PHP version. If you change some of the configuration variables (DOCUMENT_ROOT, VHOSTS_DIR etc.), then remember to change the folder structure as well.
<b>Note: It is not needed to configure the .env file.</b>
<br>
The make target 'deploy-base' depends on the variable GIT_USER that should be either your own GitHub username or your organization's name.
Please note, the target also calls another target 'db-import-prod' from our WordPress Boilerplate Site setup: https://github.com/magnussmed/wp-site-boilerplate
Feel free to delete that specific line.
<br><br>

### Fire it up!
It is time to fire up the Airbase.
Call the following command within this repository's root:
```bash
make start
```
The containers should now start to be built, and this might take a few minutes the first time.
<br>
Deploy your first git repository by calling:
```bash
make deploy-base app=<REPO_NAME>
```
This command clones your chosen GitHub repository into the www folder. When it's done, you can access the application by going to:
http://<REPO_NAME>.test
<br>
There is no limit of how many repositories the Airbase can contain, yet keep in mind having many sites running locally (fast) depends on your available resources.
<br>
You can stop the running containers by calling:
```bash
make stop
```
