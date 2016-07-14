#!c:/Perl/bin/perl.exe
########################################################
# A simple script to upload a binary file to a server
# place in the cgi-bin directory of the web server
# must have perl 5 or higher installed
# Copyright 2001 Mark Newnham (mark@newnhams.com)
# Issued under the GPL Licence
########################################################
use CGI;
$query = new CGI();
print $query->header(-type=>"text/html",
		     -expires=>"-1d");
 
#########################################################
# Check we have the correct items
# Expecting upload from an html page with an input type=file
# field called 'filename'
#########################################################
$filename = $query->param('filename');
$comment = $query->param('comment');
$okpage = $query->param('OKPage');
$notokpage = $query->param('NotOKPage');
$description =~s/ /__/g;

if ($filename eq "" )  {
    print $query->start_html(-title=>"Upload Error",
				 -style=>{-src=>'/hd.css'}),
	  $query->h2("Error Uploading file"),
	  "You must specify an upload file, please wait while you are redirected back to the input screen..." + $okpage,
	  "<META HTTP-EQUIV='REFRESH' CONTENT='2; URL=/comefrom.p'>",
	  $query->end_html;
	  exit();
}
########################################################
# Get a name for the file, This creates a name based on
# the date and time
########################################################
($day,$month,$year) = (localtime)[3,4,5];
($hour,$minute,$second) = (localtime)[2,1,0];
print $query->start_html(-title=>"Upload Process",
						-style=>{-src=>'/style/upload.css'}),
	      $query->h2("<div class=upbanner>Uploading Your File...</div>");

$temp = $filename;
$temp =~s/ //g; 
$temp =~ s/.*[\/\\](.*)/$1/;
$newfilename=sprintf("%02d%02d%02d%02d%02d%04d%s",$hour,$minute,$second,$month+1,$day,$year+1900,$temp);
$filename =~s/ /__/g; 
$filename =~ s/.*[\/\\](.*)/$1/;

#####################################################
# Copy a binary file to somewhere safe, in this
# case the c:/tmp directory on a unix box
#####################################################
open (OUTFILE,">/hdupload/$newfilename");
binmode(OUTFILE);

$fh = $query->upload('filename');

while (<$fh>) {
   print OUTFILE $_;
}  
close (OUTFILE);

#######################################################
# now move on and do something with the file
#######################################################

print "<h2>Please wait....</h2>\n";
#print "<META HTTP-EQUIV='REFRESH' CONTENT='2; URL=" + $okpage + "'>",
#	  $query->end_html;
print "<META HTTP-EQUIV='REFRESH' CONTENT='2; URL=";
print $okpage;
print "&thefile=";
print $newfilename;
print "&comment=";
print $comment;
print "'>",
	$query->end_html;

