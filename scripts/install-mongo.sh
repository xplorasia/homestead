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
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927;

echo "Creating a list file for MongoDB.";
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list;

echo "Updating the packages list";
apt-get update;

echo "Install the latest version of MongoDb";
apt-get install -y mongodb-org;

echo "Fixing the pecl errors list";
sed -i -e 's/-C -n -q/-C -q/g' `which pecl`;

echo "Installing OpenSSl Libraries";
apt-get install -y autoconf g++ make openssl libssl-dev libcurl4-openssl-dev;
apt-get install -y libcurl4-openssl-dev pkg-config;
apt-get install -y libsasl2-dev;

echo "Installing PHP7 mongoDb extension";
pecl install mongodb;
service mongod start;

echo "adding the extension to your php.ini file";
echo 'extension=mongodb.so' > /etc/php/mods-available/mongodb.ini;
ln -s /etc/php/mods-available/mongodb.ini /etc/php/7.0/cli/conf.d/mongodb.ini;
ln -s /etc/php/mods-available/mongodb.ini /etc/php/7.0/fpm/conf.d/mongodb.ini;

echo "restarting ngninx, php-fpm";
service nginx restart && service php7.0-fpm restart;

echo "adding user 'homestead' to admin collection";
echo 'use admin;
db.createUser({
	user: "homestead" ,
	pwd: "secret",
	roles: [
		"root"
	]
});' > /home/vagrant/apps/setupMongo.js
mongo admin < /home/vagrant/apps/setupMongo.js

echo "configuring /etc/mongod.conf";
sudo sed -i "s/  bindIp: 127.0.0.1/# bindIp: 127.0.0.1/g" /etc/mongod.conf
sudo sed -i "s/#security:/security:/g" /etc/mongod.conf
a="\ \ authorization: enabled"
sudo sed -i "/security:/a ${a}" /etc/mongod.conf

echo "restarting mongodb after enabling security";
service mongod restart;