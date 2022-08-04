#!/bin/bash

DISTRO=$(awk -F= '/DISTRIB_ID/ {print $2}' /etc/lsb-release | tr [:upper:] [:lower:])
APACHE_IN=$(dpkg -l apache2 | grep ^ii | wc -l)

function deploy_app(){
	wget https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip -O /tmp/main.zip
	unzip /tmp/main.zip -d /tmp
	cp -R /tmp/linux-site-dio-main/* /var/www/html/
	HASH_APP=$(curl -s http://localhost | sha256sum | awk '{print $1}')

	if [ $HASH_APP=="249add2387c67543a79d4cb4e97e4bcafc52ab6c206d98ba0052a78d64eb09ba" ]
	then
		echo "Deploy da aplicação realizado com sucesso!!!"
	else
		echo "Houve uma falha ao validar o deploy da aplicação"
	fi
}
if [ ${DISTRO}=="ubuntu" ]
then
	echo "Iniciando deploy no sistema ${DISTRO}"
	if [ $APACHE_IN -ne 1 ]
	then
		if apt-get update && apt-get upgrade -y && apt-get install apache2 -y
		then
			echo "Apache instalado com sucesso"
			$(update-rc.d apache2 defaults || systemctl enable apache2) && echo "Habilitando apache na inicialização do sistema"
			$(service apache2 start || systemctl start apache2) && echo "Daemon do apache iniciado"
			if [ $HASH_APP=="249add2387c67543a79d4cb4e97e4bcafc52ab6c206d98ba0052a78d64eb09ba" ]
			then
				echo "Deploy da aplicação já havia sido realizado!!!"
			else
				deploy_app
			fi
		else
			echo "Falha na realização do deploy do apache, abortando instalação"
		fi
	else
		deploy_app
	fi
fi
