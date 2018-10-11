Vagrant LAMP
============

Want to test a new web app but don't want to affect your current Apache / MySQL / PHP system?
Applications like MAMP are great, but they don't make it easy to maintain multiple, separate
web roots.

If you find yourself needing quick to configure web stack, but also one that is customizable try this Vagrant project

Vagrant allows for Virtual Machines to be quickly setup, and easy to use.

And this project aims to make it very easy to spinup a complete LAMP stack in a matter of minutes.

Requirements
------------
* VirtualBox <http://www.virtualbox.com>
* Vagrant <http://www.vagrantup.com>
* Git <http://git-scm.com/>

Usage
-----

### Startup
	$ git clone https://github.com/slier81/vagrant-lamp-php7.git
	$ cd vagrant-lamp
	$ vagrant up

That is pretty simple.

### Connecting

#### Apache
The Apache server is available at [10.10.10.10](http://10.10.10.10)

#### MySQL
Externally the MySQL server is available at port 8889, and when running on the VM it is available as a socket or at port 3306 as usual.  
Username: root  
Password: root

#### PhpMyadmin
PhpMyadmin is available at [10.10.10.10/phpmyadmin](http://10.10.10.10/phpmyadmin)  
Username: root  
Password: root

#### Mailcatcher
Mailcatcher is available at [10.10.10.10:1080](http://10.10.10.10:1080)

Technical Details
-----------------
* Ubuntu 18.04 64-bit
* Apache 2 (mod_rewrite preconfigured, work out of the box)
* MySQL 5.7
* PHP 7.2 (xdebug preconfigured, work out of the box)
* PhpMyadmin
* Composer
* Mailcatcher (preconfigured, work out of the box)

We are using the base Ubuntu 18.04 box from Vagrant. If you don't already have it downloaded
the Vagrantfile has been configured to do it for you. This only has to be done once
for each account on your host computer.

The web root is located in the project directory at `www` and you can install your files there

And like any other vagrant file you have SSH access with

	$ vagrant ssh  
	
### Potential Error
If u got an error while running `composer install`, this is probably due to insufficient memory.Try increase your virtualbox memory.Add below code to `Vagrantfile`
```
config.vm.provider "virtualbox" do |vb|
  vb.customize ["modifyvm", :id, "--memory", "1024"] #1gb
end
```

#### Screenshot Of Localhost
![ScreenShot](http://i.imgur.com/EDHyAdM.png)
