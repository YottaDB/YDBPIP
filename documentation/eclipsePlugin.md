# PIP Eclipse Plugin

PIP includes an [Eclipse](https://www.eclipse.org/) plugin that connects to the PIP instance and provided specialized development tools for PIP.

Note: This plugin does require a relatively old version of Eclipse.

## Installation

Prerequisties:
 * Java 1.6

Main Installation:

 1. Install [Eclipse 3.7.2](http://www.eclipse.org/downloads/packages/eclipse-classic-372/indigosr2) for your platform
 2. Clone the [PIP Repository](https://github.com/YottaDB/PIP.git)
 3. Click on "Help" => "Install New Software..."
 4. Click "Add..."
 5. In the Name field type `PIP`
 6. Click "Local..."
 7. Browse to the location of the PIP repository you cloned earlier then the directory `java/piptools`
 8. Click "Open"
 9. Click "OK"
 10. Click the checkbox by `PIP Tools`
 11. Click "Next >"
 12. Click "Next >"
 13. Click "I accept the terms of the license agreement"
 14. Click "Finish"
 15. Click "OK"
 16. Click the checkbox next to Eclipse.org...
 17. Click "OK"
 18. Click "Restart Now"

## Compilation
TBD

## Using the Plugin

### Starting a New Project

 1. Click "File" => "New" => "Other..."
 2. Click the triangle by "FIS Profile"
 3. Click "New Profile Project"
 4. Click "Next >"
 5. In the Name field give your project a name
 6. Click "Finish"

### Configuring Project Properties

This configures the Profile project to talk to a Profile Server.

 1. Right click your project in the "Package Explorer" then click "Properties"
 2. Click the triangle by "FIS Profile"
 3. Click Profile Login
 4. Click "Select..."
 5. Click "Add..."
 6. Fill out the correct information in the dialog box. Environment is just a name for the connection. The Port is the MTM port (by default 61012)
 7. Click "Test"
 8. Click "OK"
 9. Click "OK"
 10. Double click the Environment name you just added
 11. Click "OK"

### Adding Profile Resources

Profile Resources are items contained within the dataqwik folder (by default). You can add existing Profile Resources using a very similar process to adding a new Profile Resource as described below.

 1. Click the triangle by "dataqwik"
 2. Right click the resource type you want to add then click "New" => "Other..."
 3. Make sure "FIS Profile" => "New Profile Resource" is selected
 4. Click "Next >"
 5. Make sure the Target folder and type match the resource type you right clicked earlier
 6. Fill out the rest of the dialog boxes as appropriate for the resource type
 7. Click "Finish"
 8. Now you can edit the resource as necessary

### Perspectives

The Profile Eclipse plugin provides 2 different perspectives for Eclipse:

 * Profile DBA
 * Profile Developer

These are useful for the user profile described in the perspective.

#### Changing Perspectives

 1. Click "Window" => "Open Perspective" => "Other..."
 2. Select the Perspective you want (Profile DBA or Profile Developer)
 3. Click "OK"

#### Profile DBA Perspective

This perspective focuses on the tables, columns, and other information related to the DATA-QWIK DataBase Management System. This perspective loads information from the PIP instance and allows for addition and modifications to various meta-data information.

#### Profile Developer Perspective

This perspective is very similar to the default Eclipse perspective, except it changes the list of New item types to be ones from Profile (rather than Java). It also adds a few tabs that allow quick changes to different Profile environments and gives a FIS Console.
