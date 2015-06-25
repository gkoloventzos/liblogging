#!/usr/bin/perl -w
#
# Created by Georgios Koloventzos
# Columbia University - CS department
#
use strict;
use Switch;
use File::Basename;
use Getopt::Long;
use File::Find;

my @c_exts = qw(.c .cc .cpp .c++);
my @java_exts = qw(.java);
my ($dir, $lang, $message);
my $help;
my $file = "/etc/inslog.dat"; #file for log


sub print_help {
    my $string = <<"MES";
inslog.pl: Insert a log message to create a call path graph.
    -h, --help           print this message
    -l, --language       search for java files
    -d, --directory      directory to start searching for files
    -m, --message        insert string.
    -f, --file           file to print the messages
MES
  print $string;
  exit 0;
}

sub add_java {
}

sub eachFile {
  my $fn = $_;
  my $fullpath = $File::Find::name;
  #remember that File::Find changes your CWD, 
  #so you can call open with just $_
  my ($ddir, $filename, $ext) = fileparse($fn);
  switch ($lang) {
    case "java" {
      if ($ext == ".java"){
        add_java($fn,$message);
      }
    }
    case "c" { next }
    case "python"{ next }
    case "perl" { next }
    else { print "Only java available"}
  }
}



GetOptions ("language=s" => \$lang,
            "help"  => \$help,
            "directory=s" => \$dir,
            "message=s" => \$message,);

print_help() if ($help);

find (\&eachFile, $dir);

