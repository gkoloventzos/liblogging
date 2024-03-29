# liblogging
A perl script for inserting log messages for call path graph creation

If perl switch is not installed:

Unix like : `sudo cpan -f Switch`

------
##Options
```
--language|-l   :select laguage
--directoy|-d   :select directory to start search(default current)
--message|-m    :message to put (more in next section)
--exclude|-e    :exclude directories(multiple and comma seperated).
--file|-f       :output file (default /tmp/inslog.dat)
--help|-h       :this message
```

##Thoughts
```
--input|-i      :input file for message
```

##Message configuration

You can specify the log message. All language have different print functions and
how logging. So with the -m|--message you can specify the print message. keep in
mind that this script does not add any libraries. For Java for example use
qualified paths if you are not sure if the import is mentioned or not.

There are 3 place holders to be used in the message.
With strict order:

1. file: It should be used to open the output file (Thus it should be first)
2. function: The called function
3. filename: The name of the file the function resides in

e.g.

```
inlog.pl -l java -m "java.io.BufferedWriter out = new BufferedWriter(new java.io.FileWriter("%s", true));out.write("[CALLGRAPG] function %s filename %s ");out.close();catch (java.io.IOException ioe) {}"
```


CAUTION: As the style of coding is something personal and can be changed this
script can miss or add strings where it should not. I will try to minimize this
risk but you should be aware. 

_May it compile._
