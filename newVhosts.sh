#This Bash Script takes parameters and creates a new vhosts with it
# @author: Maik Nesgutski

#variables
domain=$1
rootFolder=$2 #this has to be the full path to the project
sslCert=$3 #path to the ssl cert that should be used, dont submit file endings, cert and key need to be in the same folder

if [ -z $domain ]
then
	echo "Domain cannot be empty!"
else
	echo "${domain} has been chosen as domain name"
	echo "Generating Configuration file"

	if [ -e "/etc/apache2/sites-available/${domain}.conf" ]
	then
		echo ""
		echo "Configuration file already exists. Aborting mission!"
	else
		if [ -z $rootFolder ]
		then
			echo "Document Root has been left empty, defaulting to /var/www/html"
			rootFolder="/var/www/html"
		elif [ -d $rootFolder ]
		then
			echo "${rootFolder} has been designated as project root"
			echo "Symlink is being initiated"
			
			ln -s "${rootFolder}" "/var/www/${domain}"
			
			rootFolder="/var/www/${domain}"

			echo "Vhost file is being generated"
			echo "<VirtualHost *:80>\n\tDocumentRoot ${rootFolder}\n\tServerName ${domain}\n\tServerAlias www.${domain}\n\tErrorLog \${APACHE_LOG_DIR}/error.log\n\tCustomLog \${APACHE_LOG_DIR}/access.log combine\n</VirtualHost>" > "/etc/apache2/sites-available/${domain}.conf"
			
			echo "\n"
			echo "\nChecking if ssl Certificate has been added"

			if [ -f "${sslCert}.crt" -a -f "${sslCert}.key" ]; then
				echo "<VirtualHost *:443>\n\tSSLEngine On\n\tSSLCertificateFile ${sslCert}.crt\n\tSSLCertificateKeyFile ${sslCert}.key\n\tServerAdmin nesgutski@kreyer.de\n\tDocumentRoot ${rootFolder}\n\tServername ${domain}\n\tErrorLog \${APACHE_LOG_DIR}/error.log\n\tCustomLog \${APACHE_LOG_DIR}/access.log combined" >> "/etc/apache2/sites-available/${domain}.conf\n</VirtualHost>"
				echo "SSL Certificate has been added to the VHOSTS file"
			else
				echo "No SSL path supplied"
			fi

			echo "VHOST has been generated \n"
			echo "_____________________________________"
			echo "Running a2ensite ${domain}.conf"
			a2ensite "${domain}.conf"
			service apache2 restart
		else
			echo ${result}
			echo "everything is shit. Aborting mission"
		fi

	fi
fi
