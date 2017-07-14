This directory contain toolchain for MARK II. There is sources of all tools in directory src and symbolic links in folder bin. 

In order to install tools, just create and directory for them, copy directories src and bin into this directory and add bin directory to your $PATH

For example, on Linux Mint you can do something like this:

    $ mkdir /opt/m2tools
    $ cp -r src /opt/m2tools/
    $ cp -r bin /opt/m2tools/
    $ echo "export PATH=$PATH:/opt/m2tools/bin" >> ~/.bashrc
