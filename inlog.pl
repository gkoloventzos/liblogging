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
my @exclude;
my $input;
our $file; #file for log
our $search_dir;
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
    -i, --input          input file for message
MES
  print $string;
  exit 0;
}

sub add_log {
  #seems that java and c files can be caught by this regex.
  my ($filename, $message, $ext) = @_;
  my $bla= "";
  my $msg = $message;
  tie my @lines, 'Tie::File', $filename or return 1;
  my $my_lines = scalar @lines;
  my $count = 0;
  my $find = 0;
  my $function = "";
  my $indentation = "";
  my $newline;
  for (@lines) {
    if (/$match_string{$ext}/) {
      if ($lines[$count] =~ /new/ or $lines[$count] =~ /}/) {
        $count++;
        next;
      }
      $message = $msg;
      $function = $3;
      $newline = 1;
      #skip empty and commented lines
      while ($lines[$count+$newline] =~ /^(\s*)$/ or $lines[$count+$newline] =~ /^\s*\/\/.*\s*$/) {
        $newline++;
        #exit if end of file
        return 0 if ($count+$newline == $my_lines);
      }
      #indentation of next line
      $lines[$count + $newline] =~ m/(\s*)\w*/;
      $indentation = $1;
      #skip one line funtions
      if ($lines[$count + $newline] =~ m/^(\s*)}(\s*)$/) {
        $count++;
        next;
      }
      #super and this statements must be first in contructors
      if($lines[$count+$newline] =~ m/^(\s*)super/ or $lines[$count+$newline] =~ m/^(\s*)this/) {
        $count++ and next if ($lines[$count+$newline] =~ m/new/);
        #skip multiple lines of same super statements
        if ( $lines[$count+$newline] =~ m/;$/) {
          $newline++;
        } else {
          while ($lines[$count+$newline] !~ m/.*;\s*$/) {
            $newline++;
          }
          $newline++;
        }
      }
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
  my @which_found = ($fullpath =~ /($search_dir)/);
  if ( @which_found) {
    return 0;
  }
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
            "file=s" => \$file,
            "message=s" => \$message,
            "exclude=s" => \@exclude,
            "input=s" => \$input,);

die "message and input option is mutual exclusive\n" if (scalar grep {defined($_) || $_ } $message, $input) > 1;
$file = "/tmp/inslog.dat" if (not defined($file));
@exclude = split(/,/,join(',',@exclude));
$search_dir = join('|',@exclude);

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

