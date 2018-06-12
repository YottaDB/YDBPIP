# Configuring SQuirreL SQL to connect to PIP
SquirreL SQL is an FOSS SQL Client that connects to SQL compatible database servers and supports JDBC connections.

## Prerequisites
 * [SQuirreL SQL](http://www.squirrelsql.org/)
 * PIP JDBC Jar

## Configuring
PIP isn't supported out of the box with SQuirreL SQL, we have to add it to the driver manager.

 * If it is the first time you have opened SQuirreL SQL you can cancel out of the startup wizards until you get to the main application window

### Adding the PIP Driver

 1. Click on the Drivers tab on the left of the window
 2. Click the green "+" button
 3. In the "Add Driver" Window:
    1. Enter the Name: "PIP"
    2. Enter the Example URL: protocol=jdbc:sanchez/database={PIP server IP/hostname}:{MTM Port}:SCA$IBS
       * Replace {PIP server IP/hostname} with your actual PIP server IP or Hostname
       * Replace {MTM Port} with your actual MTM Port number
 	3. Click "Add" under the "Extra Class Path" tab and select the ScJDBC.jar from the PIP repository
 	4. Click "List Drivers", the "Class Name" sanchez.jdbc.driver.ScDriver should appear
 	5. Click OK

### Adding an Alias (Connection) for PIP

 1. Click Aliases tab on the left of the window
 2. Click the green "+" button
 3. In the "Add Alias" Window:
    1. Enter the Name: "PIP"
    2. Select the Driver: PIP
    3. Enter the URL: protocol=jdbc:sanchez/database={PIP server IP/hostname}:{MTM Port}:SCA$IBS
       * Replace {PIP server IP/hostname} with your actual PIP server IP or Hostname
       * Replace {MTM Port} with your actual MTM Port number
    4. Enter the User Name: 1 (if using the defaults with PIP)
    5. Enter the Password: XXX (if using the defaults with PIP)
    6. click OK

### Connecting to PIP

 1. Click the Aliases tab on the left of the window
 2. Select the "PIP" Alias
 3. Click the first icon that looks like a plug
 4. You are now able to run SQL statements or open tables for viewing
 