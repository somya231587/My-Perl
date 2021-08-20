use warnings;
use strict;
use Data::Dumper;
use POSIX;
use DBI;
use Getopt::Std;

## to check all the DBDs installed under DBI
# print "hello";
# my @dr=DBI->available_drivers('quiet');
# foreach(@dr){
	# print $_,"\n";
# }

my $schema='world';
my $account='guest';
my $driver='mysql';
my $DBconn="DBI:$driver:$schema";
my $pass='';

sub basic{
my $dbh=DBI->connect($DBconn,$account,$pass) or die "error connecting with mysql $DBI::errstr\n";
print " --- Database $DBconn Connected --- \n" if defined $dbh;
## SQL queries
my $qh=$dbh->prepare('select * from city limit 5;') or die "couldnt execute query \n";
$qh->execute();
# while(my @row=$qh->fetchrow_array){
	# print Dumper @row,"\n";
# }
while(my $row=$qh->fetchrow_hashref){
	print Dumper $row,"\n";
}
print $qh->rows()," no of rows returned \n";
$qh->finish();
$dbh->disconnect();
}
#basic();

sub testfile{
	my $file="test.csv";
	open FH,$file or die " couldnot open $file file \n";
	our @lines=<FH>;
	foreach(@lines){chomp $_;}
	# print Dumper @lines;
	our $table_name='placed_info';
	our ($c1,$c2,$c3,$c4,$c5)=split /,/,$lines[0]; # names of the table's columns
	our $dbh=DBI->connect($DBconn,$account,$pass) or die "error connecting $DBI::errstr\n";
	print "\n --- Database $DBconn Connected --- \n" if defined $dbh;
	print "\nThis DB script operates on \n --- Table : $table_name | Schema : $schema | User: $account ---\n";
	print "\nEnter \n";
	print " 1 -> Create Table \n 2 -> Insert Into Table from File: $file \n 3 -> Fetch from table\n";
	my $choice=<STDIN>;
	create_table(@lines) if $choice==1;
	insert_data(@lines) if $choice==2;
	fetch_data() if $choice==3;
	close FH;
	
	sub create_table{
		@lines=@_;
		my $qs=$dbh->prepare("DROP TABLE IF EXISTS $table_name;");
		$qs->execute() or print " Table :$table_name doesn't exist -- Creating \n"; 
		$qs->finish(); # dropping the existing table first before recreating
		my $qh=$dbh->prepare("
		CREATE TABLE $table_name(
		$c1 INT PRIMARY KEY,
		$c2 CHAR(35) NOT NULL,
		$c3 CHAR(35) NOT NULL,
		$c4 CHAR(35) NOT NULL,
		$c5 CHAR(35) NOT NULL		);") ;
		$qh->execute() or die " Table not created : $DBI::errstr\n";
		$qh->finish();
		print " -- Table Successfully created -- \n Table Name:placed_info -- schema: $schema\n";
	}
	sub insert_data(){
		@lines=@_;my $count=0;
		my $qh=$dbh->prepare("INSERT INTO $table_name($c1,$c2,$c3,$c4,$c5)
		VALUES(?,?,?,?,?);");
		foreach(@lines[1..$#lines]){
			my ($a,$b,$c,$d,$e)=split /,/,$_;
			$qh->execute($a,$b,$c,$d,$e) or die " insertion failed \n";
			$count+=$qh->rows();
		}
		$qh->finish();
		print " $count rows successfully inserted into $table_name\n";
	}
	sub fetch_data(){
		my $qh=$dbh->prepare("SELECT * FROM $table_name ORDER BY $c4 DESC;");
		$qh->execute();
		while(my $rows=$qh->fetchrow_hashref){
			foreach(sort keys %$rows){
				print " | ",$_,"-",$rows->{$_} if $_ !~/$c1/;
			}
			print "\n";
		}
		print $qh->rows()," rows fetched\n";
		$qh->finish();
	}
	$dbh->disconnect();
	print "\n --- Database : $DBconn Disconnected ---\n"
	
}
testfile();