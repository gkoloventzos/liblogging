# liblogging
A perl script for inserting log messages for call path graph creation

If perl switch is not installed:

Unix like : `sudo cpan -f Switch`
------

You can specify the log message. All language have different print functions and
how logging. So with the -m|--message you can specify the print message. keep in
mind that this script does not add any libraries. For Java for example use
qualified paths if you are not sure if the import is mentioned or not.

You can specify $function for function name and $filename for the name of the
file (not path).
