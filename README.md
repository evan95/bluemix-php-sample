# Using ansible into delivery pipeline, IBM Cloud
This tutorial is based on the following [Link]( https://developer.ibm.com/recipes/tutorials/run-ansible-from-your-ibm-bluemix-devops-pipelines/), which had scripts updated to attend the current IBM Cloud software version.

If you are into internal Github stop right now and move to Public Github. This example is supposed to be built into Public IBM Cloud.
If you want to try into Private, I suggest reviewing Cloud Foundry offerings in order to fix that error: ```sudo: no tty present and no askpass program specified```



### Suggested reading before you move ahead
- [What is Ansible in a brief](https://learning.oreilly.com/library/view/ansible-quick-start/9781789532937/01c6351e-bb66-4de0-832a-8999fa6c724e.xhtml)
- [Architecture](https://docs.ansible.com/ansible/2.5/dev_guide/overview_architecture.html)
- [Inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#assigning-a-variable-to-one-machine-host-variables)
- [YAML Syntax](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)
- [AD-hoc commands](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html)
- [Ansible Cloud Modules](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html)
- [Windows Modules](https://docs.ansible.com/ansible/latest/modules/list_of_windows_modules.html)
- [Playbook example](https://github.com/ansible/ansible-examples)

### Running the application locally
In case you want to test the application locally, clone the application to your local directory and follow the next steps.
- Download and extract [PHP](http://php.net/downloads.php)
- Add the extracted directory to your PATH environment variable
- Download and extract the starter code from the Bluemix UI
- ```sh cd``` into the app directory
- Run ```php -S localhost:8000``` to start the app using the built-in development web server
- Access the running app in a browser at http://localhost:8000


### Explore the sample application

Review the sample source repository. These are the key elements of the repository:

- index.php – the sample application
- manifest.yml – the CloudFoundry application definition
- setup_tools/install_ansible.sh – script to set up ansible
```sh
#!/bin/bash
echo "apt-get -qq update"
sudo apt-get -qq -y update

echo "apt-get -qq -y install python2.7 python-pip"
sudo apt-get -qq -y install python2.7 python-pip
python --version

echo "apt-get -qq -y install python-dev libssl-dev libffi-dev"
sudo apt-get -qq -y install python-dev libssl-dev libffi-dev
echo "pip install pycrypto pyyaml ansible --quiet"
sudo pip install pycrypto pyyaml ansible --quiet

echo "apt-get -qq clean"
sudo apt-get -qq clean
```

- playbook.yml – the Ansible playbook determines what host name to use, then uses cf push to upload the application
```
# Publish this application to bluemix using ansible
        ---
        - name: Publish the app to Bluemix
          hosts: localhost
          connection: local
          vars:
            pipeline_id: "{{ lookup('env','PIPELINE_ID') | default('test-php-sample-1',true) }}"
            app_hostname: "{{ lookup('env','APP_HOSTNAME') | default(pipeline_id,true) }}"
          tasks:
            - debug:
                var: app_hostname
            - name: CF Push Application
              shell: "cf push -f manifest.yml -u none --hostname {{ app_hostname }}"
```

- bluemix/ – the configuration files needed to create the toolchain and pipeline

This is how your application looks like:
![Hello World](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/PHPStarter.png)

### Create the toolchain
- Authenticate to GitHub and Bluemix
- Click the Create toolchain button in the repository readme to clone the repo into your GitHub account
[![Pipeline](https://camo.githubusercontent.com/de04b4d24bc99b61c4febd82cc2cfc60a50852aa/68747470733a2f2f636f6e736f6c652e6e672e626c75656d69782e6e65742f6465766f70732f67726170686963732f6372656174655f746f6f6c636861696e5f627574746f6e2e706e67)](https://console.ng.bluemix.net/devops/setup/deploy/?repository=https://github.com/IBMCloudDevOps/bluemix-php-sample)
- Once the repository is cloned, you will be taken to the Bluemix Continuous Delivery toolchain setup. This toolchain has been defined by the template in the sample repository.
![Create Pipeline Menu](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/CreateTC2.png)
    - If you have not authenticated to GitHub you will see an Authorize button.
    ![Authorization](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/NotAuthorized.png)
    - You can select the Bluemix organization and space by clicking the Delivery Pipelines button.
    ![Authorize](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/BluemixConfig.png)
- Click the Create button. The toolchain will look like this will generate a toolchain that looks like the following
![Organization Space](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/Toolchain.png)

### Set the host name
- Select the Delivery Pipeline tile from  the toolchain view to open the pipeline stages view.
![Tool Chain View](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/PipelineTileSelected.png)
- The pipeline executes immediately after being created. That's supposed to FAIL. That's because IBM Cloud has been updated and needs to have their current software version installed. In this case, you will have php v5 in the current script, we are supposed to change it to the latest version. A simple ```sudo apt-get install php``` is supposed to install the latest version, but in this example we want you to see how to edit script.
    - For that, select the Delivery Pipeline and clicle on Build box, click on the engine buttom and select Configure Stage and enter the new script:
```
#!/bin/bash
#Install PJP

echo "apt-get -qq update"
sudo apt-get -qq update


echo "sudo apt-get -qq -y install php7.2 php7.0-fpm"
sudo apt-get -qq -y install php7.0 php7.0-fpm 
sudo php --version

echo "apt-get -qq clean"
sudo apt-get -qq clean

#Lint the PHP source
echo "Lint the PHP source"
php -l *.php

```
- Ansible Deploy stage is correctly setup, but notice that ```setup_tools/install_ansible.sh``` into github also points to specific version of python, so review that script also.
- Once finished editing the Build stage, click on Play to re-execute your script. The stage will be triggered, and if completed correctly, Ansible Deploy is also supposed to start automatically. You view will look like this once the build completes.
    - If you face something wrong, click on View logs and history, you are supposed to be able to track the error. 
![Pipeline View](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/PipelineStages.png)
- Click on the gear at the top right corner of the **Ansible Deploy** stage to select **Configure Stage**
- Set a unique hostname in the APP_HOSTNAME variable under Environment Properties tab of this stage. This field will initially be blank, which causes the Ansible playbook to use the pipeline's UUID for the hostname.
![Deploy Configuration](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/DeploySettings.png)
- Run the Ansible Deploy stage using the Run Stage button at the top righthand side of the stage’s card

### See the application in Bluemix
- Click the menu on the upper left of the Bluemix interface. Choose Dashboard to display all the applications.
![Side Menu](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/BMDashboardMenu.png)
- The PHP sample application will appear in the Bluemix Apps Dashboard
![Dashboard](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/BMDashboard.png)
- Click the Route link to launch the sample application.
![Hello World](https://developer.ibm.com/recipes/wp-content/uploads/sites/41/2017/02/PHPStarter.png)
- Now if you want, edit the ```index.php``` to a HTML webpage, or php, and see how the pipeline works from end-to-end and how fast is to deploy an application. Here is a sample HTML webpage for you :-)
```
<!DOCTYPE HTML>
<!--
	Eventually by HTML5 UP
	html5up.net | @ajlkn
	Free for personal and commercial use under the CCA 3.0 license (html5up.net/license)
-->
<html>
	<head>
		<title>Eventually by HTML5 UP</title>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
		<link rel="stylesheet" href="assets/css/main.css" />
	</head>
	<body class="is-preload">
		<!-- Header -->
			<header id="header">
				<h1>Eventually</h1>
				<p>A simple template for telling the world when you'll launch<br />
				your next big thing. Brought to you by <a href="http://html5up.net">HTML5 UP</a>.</p>
			</header>
		<!-- Signup Form -->
			<form id="signup-form" method="post" action="#">
				<input type="email" name="email" id="email" placeholder="Email Address" />
				<input type="submit" value="Sign Up" />
			</form>
		<!-- Footer -->
			<footer id="footer">
				<ul class="icons">
					<li><a href="#" class="icon brands fa-twitter"><span class="label">Twitter</span></a></li>
					<li><a href="#" class="icon brands fa-instagram"><span class="label">Instagram</span></a></li>
					<li><a href="#" class="icon brands fa-github"><span class="label">GitHub</span></a></li>
					<li><a href="#" class="icon fa-envelope"><span class="label">Email</span></a></li>
				</ul>
				<ul class="copyright">
					<li>&copy; Untitled.</li><li>Credits: <a href="http://html5up.net">HTML5 UP</a></li>
				</ul>
			</footer>
		<!-- Scripts -->
			<script src="assets/js/main.js"></script>
	</body>
</html>
``` 

### Closing thoughts

The Bluemix Continuous Delivery service provides a flexible continuous delivery pipeline that can employ a variety of technologies to effect deployments. Ansible provides an open, all purpose deployment and configuration management framework. Together they give you effective continuous delivery using an open platform for deployment. 
