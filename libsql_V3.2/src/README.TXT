OVERVIEW: 

This is the readme file for the dynamic link library libsql.a provided by
Sanchez Computer Associates. The purpose of the library is to facilitate
the development of client software which interacts with Sanchez's server
software PROFILE/Anyware. The library is intended to be used
with clients that wish to send SQL commands into PROFILE/Anyware.

In order to communicate with PROFILE, SQL commands must be constructed in
a specific format which the server can
understand. Similarly, the server responds to commands with messages
constructed in this same format. In addition, since PROFILE/Anyware is a
client/server application designed to be run over a network, a
communications library is necessary which understands TCP/IP on a Unix
platform. This library, libsql.a, facilitates writing client software
which interacts with PROFILE by hiding many of the details of this
Client/Server interaction.  Using this library clients can send SQL
commands, and receive responses, without having to be concerned with the
underlying details of this communication.

WHAT YOU NEED TO KNOW AND PRE-REQUESITS FOR USING THIS LIBRARY

While this library simplifies the interaction between clients and the
PROFILE server it does not completely obviate the need to understand the
architecture of PROFILE's database. In order to send SQL commands a
knowledge of the tables and columns in the PROFILE database is needed.
Consult the documents "PROFILE Enterprise Server Architecture -- Technical
Specification" for additional information. Detailed specifications for
using this library can be found in the document "PROFILE CLIENT API'S" 
document number 23907. For additional help please call Sanchez Computer
Associates @ 610 578 5544 and ask to speak to the Technology Development
Group.

Since this library communicates with the PROFILE server it presupposes
that two processes are running in the background, Sanchez's Message
Transport Manager (MTM) and at least one PROFILE server. In addition, you
need to know the IP address of the machine which the server is running on
as well as the TCP/IP Port the MTM is using. Consult the systems manager
at your site for this information. 

HOW TO USE THIS LIBRARY  

The document "PROFILE CLIENT API'S", document number 23907 contains
detailed descriptions of each callable routine in this library. To access
this library you need to link it into your code at link time. A typical
compile command on AIX would look like this. 

cc my_c_code.c -lsql -L/ location_of_library

my_c_code.c is the source code for your c code.
-lsql tells the compiler to look for this library (Full name libsql.a.)
-L/location_of_library is the full path name of where the library is stored.
So for example if you want to compile a program called example.c and you
want the compiler to look in the directory /SCA/sca_gtm/extcall

cc example.c -lsql -L/SCA/sca_gtm/extcall

Please keep in mind that this is a DYNAMIC link library, i.e. the routines
are not actually inserted into the executable program. Instead they are
dynamically linked into the executable code at run time. This presupposes
that the loader can find the library even after successfully creating an
executable program. If the library is moved or deleted after linking you
will not be able to run your program. You can avoid using the -L/
location_of_library if you put the library in /usr/lib. Consult your
systems manager for help in doing this. 

On Digital Unix, OSF, you need to tell the loader where to find the
library if it is not in /usr/lib.  To do this use the environment variable
LD_LIBRARY_PATH . For example

export LD_LIBRARY_PATH="/location_of_library"

Each of the routines in this library returns a variety of error codes. You
should check for these codes upon return of each routine. Consult the
specifications mentioned above for more details on the structure and
meaning of these codes. 

An example file is included which calls each of the APIs in this library.
It is called example.c . Numerous other examples are also included. They
use the naming convention ts*.c .

HOW TO INSTALL THIS LIBRARY

If you are using either AIX 4.x, Digital Unix OSF or HPUnix you will be
given a single compiled library file which you can link to as described
above. However, if you are using another version of Unix, such as SCO or
Sun's you will need to compile this library from the souce code. In that
case you will be given a tar file which includes all of the source code
necessary to do this, as well as EXAMPLE make files. Please note, that
these make files were developed on AIX 4.2 and will not necessarily work
as is on other versions of Unix, such as SCO. To create the executeable
source code do the following:

1) Untar the file sca_api.tar. First copy it into a directory of your
choice. Second execute the tar command:

tar -xvf/the_path_name/sca_api.tar  

Once this is done you will have all of the necessary source code in one
directory

2) In order to compile the code into an executeable library you
will then have to define an environment variable called LIBDIR . This
variable needs to be set to the pathname of the files. Use a command
similar to the one listed below

export LIBDIR="/the_path_name"   #THIS IS CASE SENSITIVE

3) You can then make the source code with the command make. Please note
again, that the make files included were developed for AIX 4.2, and are
not guaranteed to work as is on other versions of Unix such as SCO. In all
probability you will have to change some of the switches. You can list all
of the included make files by executing the command

ls -alp *.mk

4) This is an example sequence of command used to make the library
cd /SCA/sca_gtm/libsql
export LIBDIR=.  #TELL THE COMPILER TO LOOK IN THE CURRENT DIR
make

To link in a program which calls the routines in libsql:
cc example.c -L/SCA/sca_gtm/extcall -lsql 


CHECKING THE VERSION
Included with this package is a program called getversion (made from
version.c) which returns the current version of the library. Simply type
./getversion to report the library's version and date. If you need to make
this program you can do so using a command similar to the one above:

cc -o getversion version.c -L/SCA/sca_gtm/extcall -lsql
