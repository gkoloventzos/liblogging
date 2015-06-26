# liblogging
A perl script for inserting log messages for call path graph creation

If perl switch is not installed:

Unix like : `sudo cpan -f Switch`

------
Message configuration

You can specify the log message. All language have different print functions and
how logging. So with the -m|--message you can specify the print message. keep in
mind that this script does not add any libraries. For Java for example use
qualified paths if you are not sure if the import is mentioned or not.

You can specify $function for function name and $filename for the name of the
file (not path).

```
inlog.pl -l java -m "LOG.info(\"[CALLGRAPH] Function $function on $filename\");"
```


CAUTION: As the style of coding is something personal and can be changed this
script can miss or add strings where it should not. I will try to minimize this
risk but you should always look a bit of yourself. May it compile.
