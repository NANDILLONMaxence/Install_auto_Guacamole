#!/bin/bash

# Variables pour les liens des paquets Guacamole
guacamole_server_link="https://archive.apache.org/dist/guacamole/1.5.5/source/guacamole-server-1.5.5.tar.gz"
guacamole_webapp_link="https://archive.apache.org/dist/guacamole/1.5.5/binary/guacamole-1.5.5.war"
guacamole_auth_jdbc_link="https://archive.apache.org/dist/guacamole/1.5.5/binary/guacamole-auth-jdbc-1.5.5.tar.gz"
guacamole_auth_jdbc="guacamole-auth-jdbc-mysql-1.5.5.jar"
mysql_connector_link="https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.0.0.tar.gz" # Debian 12
mysql_connector="mysql-connector-j-9.0.0.jar"

# Variable pour la couleur des messages
color_B="\033[1;34m"  # Bleu clair
color_R="\033[1;31m"  # Rouge clair
color_G="\033[1;32m"  # Vert clair
reset_color="\033[0m"  # Réinitialisation de la couleur

# Fonction pour afficher les messages avec couleur et délai
show_message() {
    echo -e "${color_B}$1${reset_color}"
    sleep 1.5
}

# Fonction pour afficher les messages d'erreur avec couleur et délai
error_message() {
    echo -e "${color_R}$1${reset_color}"
    sleep 1.5
}

# Fonction pour afficher les messages avec couleur et délai
info_message() {
    echo -e "${color_G}$1${reset_color}"
    sleep 1.5
}

# Fonction pour vérifier la distribution
check_distribution() {
    show_message "Vérification de la distribution utilisée..."
    # Déterminer la distribution Linux
    os_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')

    # Déterminer la version de la distribution
    os_version=$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release | tr -d '"')

    # Vérifier si la distribution est prise en charge
    if [ "$os_name" = "Debian GNU/Linux" ]; then
        info_message $os_name $os_version
        lib_os="libjpeg62-turbo-dev"
        case $os_version in
            "10"|"11")
                install_prerequisites
                ;;
            *)
                error_message "The distribution is not Debian 10 or 11. Do you want to continue despite the version incompatibility ? (yes/no):"
                read -p "" choix_utilisateur

                if [ "$choix_utilisateur" = "yes" ] || [ "$choix_utilisateur" = "y" ]; then
                    show_message "Continuation of the script despite version incompatibility."
                else
                    error_message "Stopping the script."
                    exit 1
                fi
                ;;
        esac
    elif [ "$os_name" = "Ubuntu" ]; then
        info_message $os_name $os_version
        lib_os="libjpeg-turbo8-dev"
        install_prerequisites
    else
        error_message "This script only supports Debian-based distributions ."
        exit 1
    fi
}

# Installation des prérequis
install_prerequisites() {
    show_message "Installing prerequisites..."
    apt-get install sudo -y
    sudo apt-get update
    sudo apt-get install -y build-essential libcairo2-dev $lib_os libpng-dev libtool-bin uuid-dev libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev

    if [ $? -ne 0 ]; then
        error_message "Failed to install prerequisites. Exiting."
        exit 1
    fi
    show_message "Prerequisites installed successfully."
}

# Installation de Guacamole Server
install_guacamole_server() {
    show_message "Installing Guacamole Server..."
    cd /tmp
    wget $guacamole_server_link
    tar -xzf $(basename $guacamole_server_link)
    cd $(basename -s .tar.gz $guacamole_server_link)
    sudo ./configure --with-init-dir=/etc/init.d
    sudo make
    sudo make install
    sudo ldconfig

    if [ $? -ne 0 ]; then
        error_message "Failed to install Guacamole Server. Exiting."
        exit 1
    fi
    show_message "Guacamole Server installed successfully."
}

# Création du répertoire de configuration
create_config_directory() {
    show_message "Creating configuration directory..."
    sudo mkdir -p /etc/guacamole/{extensions,lib}
    show_message "Configuration directory created."
}

# Installation de Tomcat9
install_tomcat9() {
    show_message "Installing Tomcat9..."
    sudo apt-get install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-user

    if [ $? -ne 0 ]; then
        error_message "Failed to install Tomcat9. Exiting."
        exit 1
    fi
    show_message "Tomcat9 installed successfully."
}

# Téléchargement et déploiement de la Web App Guacamole
deploy_guacamole_webapp() {
    show_message "Deploying Guacamole Web App..."
    cd /tmp
    wget $guacamole_webapp_link
    sudo mv $(basename $guacamole_webapp_link) /var/lib/tomcat9/webapps/guacamole.war
    sudo systemctl restart tomcat9

    if [ $? -ne 0 ]; then
        error_message "Failed to deploy Guacamole Web App. Exiting."
        exit 1
    fi
    show_message "Guacamole Web App deployed successfully."
}

# Installation de MariaDB Server
install_mariadb() {
    show_message "Installing MariaDB Server..."
    sudo apt-get install -y mariadb-server

    if [ $? -ne 0 ]; then
        error_message "Failed to install MariaDB Server. Exiting."
        exit 1
    fi
    show_message "MariaDB Server installed successfully."

    show_message "Securing MariaDB installation..."
	show_message "MariaDB installation secured."
	show_message "Default = n ; y ; y ; y ; y ; y"
    sudo mysql_secure_installation
}

# Configuration de la base de données Guacamole
configure_guacamole_db() {
    show_message "Configuring Guacamole database..."
    sudo mysql -u root -p <<EOF
CREATE DATABASE guacadb;
CREATE USER 'guaca_nachos'@'localhost' IDENTIFIED BY 'P@ssword!';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacadb.* TO 'guaca_nachos'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF
    show_message "Guacamole database configured successfully."
}

# Téléchargement et configuration des extensions MySQL Guacamole
setup_guacamole_mysql_extension() {
    show_message "Setting up Guacamole MySQL extension..."
    cd /tmp
    wget $guacamole_auth_jdbc_link
    tar -xzf $(basename $guacamole_auth_jdbc_link)
    sudo mv $(basename -s .tar.gz $guacamole_auth_jdbc_link)/mysql/$guacamole_auth_jdbc /etc/guacamole/extensions/

    wget $mysql_connector_link
    tar -xzf $(basename $mysql_connector_link)
    sudo cp $(basename -s .tar.gz $mysql_connector_link)/$mysql_connector /etc/guacamole/lib/

    cd $(basename -s .tar.gz $guacamole_auth_jdbc_link)/mysql/schema/
    cat *.sql | sudo mysql -u root -p guacadb

    show_message "Configuration of Guacamole MySQL extension completed."
}

# Configuration du fichier guacamole.properties
configure_guacamole_properties() {
    show_message "Configuring guacamole.properties..."
    sudo tee /etc/guacamole/guacamole.properties <<EOF
# MySQL
mysql-hostname: 127.0.0.1
mysql-port: 3306
mysql-database: guacadb
mysql-username: guaca_nachos
mysql-password: P@ssword!
EOF
    show_message "guacamole.properties configured."
}

# Configuration du fichier guacd.conf
configure_guacd_conf() {
    show_message "Configuring guacd.conf..."
    sudo tee /etc/guacamole/guacd.conf <<EOF
[server]
bind_host = 0.0.0.0
bind_port = 4822
EOF
    show_message "guacd.conf configured."
}

# Redémarrage des services
restart_services() {
    show_message "Restarting services..."
    sudo systemctl restart tomcat9 guacd mariadb
    show_message "Services restarted."
}

# directory_security() {
#     show_message "Reinforcing directory security..."
#     sudo chmod 700 /etc/guacamole/extensions
#     sudo chown -R root:root /etc/guacamole/extensions
#     sudo chmod 700 /etc/guacamole/lib
#     sudo chown -R root:root /etc/guacamole/lib
#     show_message "Directory security completed successfully."
# }


# Script principal
main() {
	check_distribution
    #install_prerequisites
    install_guacamole_server
    create_config_directory
    install_tomcat9
    deploy_guacamole_webapp
    install_mariadb
    configure_guacamole_db
    setup_guacamole_mysql_extension
    configure_guacamole_properties
    configure_guacd_conf
    restart_services
    #directory_security

    echo -e "\033[1;32mGuacamole installation completed successfully!\033[0m"
    echo "------------------------------------------------------------"
    echo ""
	show_message "Please Change :"
	show_message "mysql-username: guaca_nachos"
	show_message "mysql-password: P@ssword!"
	show_message "In your data base and guacamole.properties"
	echo "-----------------------------------------------------------"
	show_message "Open your preferred web browser on your local computer."
	show_message "Navigate to the URL: [ip]:8080/guacamole."
    show_message "default user : guacadmin"
    show_message "default password : guacadmin"
    echo "-----------------------------------------------------------"

}

# Exécution du script principal
main