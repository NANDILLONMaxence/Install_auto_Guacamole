# Automated Guacamole Bastion Installation

This script automates the installation process for setting up a Guacamole bastion server on any Linux system. It downloads and installs the necessary components such as Guacamole Server, Tomcat9, MariaDB Server, and configures them for a functional Guacamole setup.

## Prerequisites

- `sudo` or administrative privileges on your Linux system.
- Internet connection to download packages.
- Compatible Linux distribution: Debian 10/11 ..., Ubuntu (other distributions may require additional steps).

## Features

- Downloads and installs Guacamole Server, Web App, and JDBC authentication extension.
- Sets up Tomcat9 for serving the Guacamole Web App.
- Installs and secures MariaDB Server for the Guacamole database.
- Configures Guacamole properties and guacd settings.
- Restarts necessary services for changes to take effect.

## Installation Instructions

1. Clone the repository or download the `001_Guacamole_Debian-all.bash` script:

    ```bash
    git clone https://github.com/NANDILLONMaxence/Install_auto_Guacamole
    ```

2. Navigate to the script directory:

    ```bash
    cd Install_auto_Guacamole
    ```

3. Make the script executable:

    ```bash
    chmod +x 001_Guacamole_Debian-all.bash
    ```

4. Run the script:

    ```bash
    ./001_Guacamole_Debian-all.bash
    ```

5. Follow the on-screen instructions to complete the Guacamole installation.

## Configuration

- Default username and password for Guacamole Web App: `guacadmin/guacadmin`.
- After installation, change the MySQL credentials in `guacamole.properties` and your MySQL database.

## Notes

- This script is tested on Debian 10/11 and Ubuntu. Additional steps may be needed for other distributions.
- Please review and customize the script as needed for your environment.

## Contributions

Contributions are welcome! If you have suggestions or improvements, feel free to open an issue or submit a pull request.
