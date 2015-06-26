#!/usr/bin/perl -w
#
# Created by Georgios Koloventzos
# Columbia University - CS department
#
use strict;
use Switch;
use Cwd;
use File::Basename;
use Getopt::Long;
use File::Find;
use Tie::File;

my @c_exts = qw(.c .cc .cpp .c++);
my @java_exts = qw(.java);
my ($lang, $message) = "";
my $dir = getcwd;
my $help;
my $file = "/etc/inslog.dat"; #file for log
my %match_string = ( '.java' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.c' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.cpp' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.cc' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.h' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.pl' => '((\w+)\s+(\w+)\s*(:\s*\w*(\(([^)]*)\)\s*)*|\(([^)]*)\))*\s*\{)',
                   );

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

sub add_brackets {
  #seems that java and c files can be caught by this regex.
  my ($filename, $message, $ext) = @_;
  tie my @lines, 'Tie::File', $filename or return 1;
  my $count = 0;
  my $find = 0;
  my $function = "";
  my $indentation = "";
  for (@lines) {
    if (/$match_string{$ext}/) {
      $function = $3;
      #found correct indentation of next line
      $lines[$count+1] =~ m/(\s*)\w*/;
      $indentation = $1;
      splice @lines, $count+1, 0, $indentation."LOG.info(\"[CALLGRAPH] Function $function on $filename\");";
      print "$_\n";
    }
    $count++;
  }
  untie @lines;
  return 0;
}

sub eachFile {
  my $fn = $_;
  return 0 if ($fn eq ".");
  my $fullpath = $File::Find::name;
  #remember that File::Find changes your CWD, 
  #so you can call open with just $_
  my ($filename, $ddir, $ext) = fileparse($fullpath, qr/\.[^.]*/);
  switch ($lang) {
    case "java" {
      if ($ext eq ".java"){
        add_brackets($fn,$message, $ext);
      }
    }
    case "c" { add_brackets($fn,$message,$ext) if ($ext eq ".c" or $ext eq ".cc" or $ext eq ".cpp" or $ext eq ".c++"); }
    case "perl" { add_brackets($fn,$message,$ext) if ($ext eq ".pl" ); }
    case "python"{ next }
    else { print "Only java available"}
  }
}

GetOptions ("language=s" => \$lang,
            "help"  => \$help,
            "directory=s" => \$dir,
            "message=s" => \$message,);

print_help() if ($help);
print "No language specified\n" and exit 0 if ($lang eq "");

find (\&eachFile, $dir);

