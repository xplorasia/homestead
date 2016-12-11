#!/usr/bin/env bash
# Check If Maria Has Been Installed

if [ -f /home/vagrant/.mongo ]
then
    echo "MongoDB already installed."
    exit 0
fi

touch /home/vagrant/.mongo

echo "MongoDB install  script with PHP7 & nginx [Laravel Homestead]"
echo "By Zakaria BenBakkar, @zakhttp, zakhttp@gmail.com"

echo "Importing the public key used by the package management system";
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6

echo "Creating a list file for MongoDB.";
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

echo "Updating the packages list";
sudo apt-get update;

echo "Install the latest version of MongoDb";
sudo apt-get install -y mongodb-org;

echo "Fixing the pecl errors list";
sudo sed -i -e 's/-C -n -q/-C -q/g' `which pecl`;

echo "Installing OpenSSl Libraries";
apt-get install -y autoconf g++ make openssl libssl-dev libcurl4-openssl-dev;
apt-get install -y libcurl4-openssl-dev pkg-config;
apt-get install -y libsasl2-dev;

echo "Installing PHP7 mongoDb extension";
sudo pecl install mongodb-1.1.9;

echo "adding the extension to your php.ini file";
sudo echo  "extension = mongodb.so" >> /etc/php/7.1/cli/php.ini;
sudo echo  "extension = mongodb.so" >> /etc/php/7.1/fpm/php.ini;

echo "Add mongodb.service file"
cat >/etc/systemd/system/mongodb.service <<EOL
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target
[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf
[Install]
WantedBy=multi-user.target
EOL

sudo systemctl start mongodb
sudo systemctl status mongodb
sudo systemctl enable mongodb

echo "restarting nginx, php-fpm";
sudo service nginx restart && sudo service php7.1-fpm restart

echo "adding user 'homestead' to admin collection";
cat >/home/vagrant/setupMongo.js <<EOL
use admin;
db.createUser({
	user: "homestead" ,
	pwd: "secret",
	roles: [
		"root"
	]
});
EOL
mongo admin < /home/vagrant/setupMongo.js

echo "configuring /etc/mongod.conf";
sudo sed -i "s/  bindIp: 127.0.0.1/# bindIp: 127.0.0.1/g" /etc/mongod.conf
sudo sed -i "s/#security:/security:/g" /etc/mongod.conf
a="\ \ authorization: enabled"
sudo sed -i "/security:/a ${a}" /etc/mongod.conf

echo "restarting mongodb after enabling security";
sudo service mongodb restart;