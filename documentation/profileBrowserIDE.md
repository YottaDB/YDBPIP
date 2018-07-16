# PIP Browser IDE

PIP provides a browser based IDE. This IDE is built using Java and runs on Apache Tomcat.

# Important notes

The browser based IDE is built using older tool chains and may not work on all browsers. It is known not to work on Google Chrome. Firefox seems to work much better for this application

# Manual Installation

These instructions are based on Ubuntu based systems.

 1. Install Java 1.8 (This will work with OpenJDK)
    ```
    sudo apt-get install default-jdk
    ```
 2. Install [Apache Tomcat 6](https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.53/bin)
    ```
    curl -fSsLO https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.53/bin/apache-tomcat-6.0.53.tar.gz
    tar xzf apache-tomcat-*.tar.gz -C /opt
    rm -f apache-tomcat-*.tar.gz
    ```
 3. Download the [Apache Derby](http://www-us.apache.org/dist//db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-lib.zip) driver and move the required libraries into the Apache Tomcat classpath
    ```
    curl -fSsLO http://www-us.apache.org/dist//db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-lib.zip
    unzip db-derby-*.zip
    mv db-derby-*-lib/lib/derbyclient.jar /opt/apache-tomcat-*/lib/
    mv db-derby-*-lib/lib/derby.jar /opt/apache-tomcat-*/lib/
    mv db-derby-*-lib/lib/derbyrun.jar /opt/apache-tomcat-*/lib/
    mv db-derby-*-lib/lib/derbytools.jar /opt/apache-tomcat-*/lib/
    rm -rf db-derby-*-lib
    rm -f db-derby-*-lib.zip
    ```
 4. Clone the PIP repository (if you haven't already)
    ```
    git clone https://github.com/YottaDB/pip.git
    ```
 5. Extract the Apache Derby Database for use by the Profile Browser IDE (modify the source path as necessary)
    ```
    tar xvzf pip/ProfileBrowserIDE/profile_ide_db.tgz -C /opt
    ```
 6. Start Apache Tomcat
    ```
    /opt/apache-tomcat-*/bin/catalina.sh start
    ```
 7. Deploy the Profile Browser IDE Web Archive (war)
    ```
    cp pip/ProfileBrowserIDE/ProfileBrowserIDE.war /opt/apache-tomcat-*/webapps
    ```
 8. Modify the JDBC url for the Apache Derby Database
    ```
    perl -pi -e 's#jdbc:derby:profile_ide_db#jdbc:derby:/opt/profile_ide_db#g' /opt/apache-tomcat-*/webapps/ProfileBrowserIDE/WEB-INF/applicationContext-acegi-security.xml
    ```
 9. Restart Apache Tomcat
    ```
    /opt/apache-tomcat-*/bin/catalina.sh stop && /opt/apache-tomcat-*/bin/catalina.sh start
    ```
 10. The Browser IDE should be available at `hostname:8080/ProfileBrowserIDE/`

# Docker Installation

The Profile Browser IDE installation is included in the Dockerfile included in this repo.

# User Accounts

The following user accounts are created in the Profile IDE Database (which are separate from the main PIP database)

User      Password  Access
====      ========  ======
webadmin  xxxx      Admin
e0101001  xxxx      User
