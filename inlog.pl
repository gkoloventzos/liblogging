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
my ($lang, $message, $message_file) = "";
my $dir = getcwd;
my $help;
our $file = "/tmp/inslog.dat"; #file for log
my %match_string = ( '.java' => '(([\w,<,>]+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.c' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.cpp' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.cc' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.h' => '((\w+)\s+(\w+)\s*\(([^)]*)\)\s*\{)',
                     '.pl' => '((\w+)\s+(\w+)\s*(:\s*\w*(\(([^)]*)\)\s*)*|\(([^)]*)\))*\s*\{)',
                     '.py' => '((\w+)\s+(\w+)\s*(\(([^)]*)\))*\s*:)',
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

sub add_log {
  #seems that java and c files can be caught by this regex.
  my ($filename, $message, $ext) = @_;
  tie my @lines, 'Tie::File', $filename or return 1;
  my $count = 0;
  my $find = 0;
  my $function = "";
  my $indentation = "";
  my $newline;
  for (@lines) {
    print $_."\n";
    if (/$match_string{$ext}/) {
      my $bla = "";
      $function = $3;
      $newline = 1;
      #found correct indentation of next line
      $lines[$count+1] =~ m/(\s*)\w*/;
      $indentation = $1;
      $newline++ if($lines[$count+1] =~ m/super/);
      $message = sprintf $message => $file, $function, $filename;
      $bla = "\n".$indentation;
      $message =~ s/\\n/$bla/g;
      splice @lines, $count+$newline, 0, $indentation.$message;
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
    case "java" { add_log($fn,$message, $ext) if ($ext eq ".java"); }
    case "c" { add_log($fn,$message,$ext) if ($ext eq ".c" or $ext eq ".cc" or $ext eq ".cpp" or $ext eq ".c++"); }
    case "perl" { add_log($fn,$message,$ext) if ($ext eq ".pl" ); }
    case "python"{ add_log($fn,$message,$ext) if ($ext eq ".py" ); }
    else { print "Language $lang is not supported.\n"}
  }
}

GetOptions ("language=s" => \$lang,
            "help"  => \$help,
            "directory=s" => \$dir,
            "message=s" => \$message,);

my ($script, $path) = fileparse($0);

#print $message;
if (not -e "$path/.place" and not $message ) {
  print "You have not specified the message for insertion\n Run: inlog -m|--message \"Your string\"\n";
  exit 0;
}

if ($message) {
  unless(open FILE, '>'.$path.".place") { die "Unable to create .place file"; }
  print FILE $message."\n";
} else {
  unless(open FILE, '<'.$path.".place") { die "Unable to create .place file"; }
  $message = <FILE>;
}
close FILE;

print_help() if ($help);
print "No language specified\n" and exit 0 if ($lang eq "");

#create the file to be sure that will have output
unless(open FILE, '>'.$file) {
    # Die with error message
    #   # if we can't open it.
    die "Unable to create $file";
}
close FILE;

#our $java_message="try {java.io.BufferedWriter out = new java.io.BufferedWriter(new java.io.FileWriter(\"$file\", true));out.write(\"[CALLGRAPG] function $function file filename $filename \");      out.close();} catch (java.io.IOException ioe) {}";
find (\&eachFile, $dir);

