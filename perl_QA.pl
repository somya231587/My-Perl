use strict;
use warnings;
use Data::Dumper;
use DateTime;
use Getopt::Std;
use Cwd;
#use CGI qw(:all);
use POSIX;


#002 Difference between 2 dates
sub dates_difference{
my $date2=DateTime->new(
	day=>14,
	month=>07,
	year=>2021,
	hour=>11);print "Date 1: ",$date2,"\n";
my $date3=DateTime->new(
	day=>14,
	month=>07,
	year=>2020,
	hour=>11);print "Date 2: ",$date3,"\n";
my $datediff=$date2-$date3;
#print Dumper %$datediff;
my $months=%$datediff{'months'};
my $days=%$datediff{days};
my $mins=%$datediff{minutes};
my $secs=%$datediff{seconds};

$date2=DateTime::epoch($date2); #epoch() returns the unicode time of DateTime object in secs from Jan 1 1970
$date3=DateTime::epoch($date3);
my $diff=($date2>$date3)?$date2-$date3:$date3-$date2;
print "\nDifference between two dates is: ",$diff/(24*3600),"days\n";
}
#dates_difference();

#003 Mail header
sub reading_STDIN{
	my $mailval=shift;
	print "accessing STDIN\n";
	print <$mailval>;
	#close $mailval;
}
#reading_STDIN(*STDIN);

#004 Anagram
sub anagram{
	my %word_hash;
	print "\n anagram test\n";
	while(<>){
		chomp $_;
		my $word_key=join "",sort(split(//,lc $_)); # sorting the wordstp store as keys
		if(!$word_hash{$word_key}){
			$word_hash{$word_key}=[$_];
		}
		else{
			my $ref=$word_hash{$word_key};
			push @$ref,$_;
		}
	 }
	foreach(values %word_hash){
		print Dumper sort @$_,"\n";
	}
}
#anagram();

#006 Number readable range
sub num_read{
	print "enter string of number series\n";
	my $num=<STDIN>;
	chomp $num;
	my @numlist=split //,$num;
	@numlist=sort @numlist;
	my $len=scalar @numlist;
	my $entry;
	my $orig=$numlist[0];
	for my $i(0..$len-1){
		unless( $numlist[$i+1]-$numlist[$i]>1 or $i==$len-1){
			next;
		}
		$entry.=$orig."-".$numlist[$i]."," if $numlist[$i]!=$orig; #for consecutive numbers
		$entry.=$orig if $numlist[$i]==$orig; #for non consecutive
		$orig=$numlist[$i+1] if $i<$len; #keeping the next number as reference for next loop
	}
	print $entry;
}
#num_read();

#008 Word Dictionary Game
sub wordgame{
	my %worddict;
	print<<HELP;
	Enter the file name while executing on CLI
HELP
	while(<>){
		chomp $_;
		$worddict{$_}=[] if defined $_ && length($_)>3;
	}
	# iterating through each key and slicing 4 letters into the array ref values
	foreach (keys %worddict){
		my $start=0;my $end=4;
		my $len=length $_;
		my $arr_ref=$worddict{$_};
		while($end<=$len){	
			push @$arr_ref,substr($_,$start,4);
			$start+=1;
			$end+=1;
		}
	}
	print Dumper values %worddict;
}
#wordgame();

#012 histogram
sub histogram{
	my @numbers=@_;
	print ref @numbers;
	my $stars;
	my %num_star;
	my $count;
	my $max= (sort {$a <=> $b} @numbers)[-1];
	## adding stars as per the number
	foreach (@numbers){
		$count=1;$stars="";
		my $diff=$max-$_;
		while($diff>0){
			$stars.=" ";
			$diff-=1;
			$count+=1;
		}
		while($count<=$max){
			$stars.="*";
			$count+=1;
		}
		$num_star{$_}=$stars;
	}
	## joining the stars of each key value pair to form histogram
	print "\n<<HISTOGRAM>>\n\n";
	$count=0;
	while($count<$max){
		my $graph="";
		foreach(values %num_star){
			$graph.=(split(//,$_))[$count]; ##breaking & joining with other values pairs based on index count
		}
		print $graph,"\n";
		$count+=1;
	}
	print keys %num_star;
	
	open OUT,("|icp.pl");
	print OUT keys %num_star;
	print "\nexternal program executed\n";
	# system "icp.pl","hello";
}
#histogram(1,3,2,5,9,4,8,15,10);

#014 list files in html
sub lisfiles{
	my %switch;
	my $dir;
	getopts('d:',\%switch);
	if(defined $switch{d}){
		$dir=$switch{d};
	}
	else{
		print<<HELP;
		enter -d: directory name <as argument>
HELP
		$dir=Cwd::abs_path();
	}
	opendir OUT,$dir;
	my @files=readdir OUT;
	@files=sort @files;
	print "content-type: text/html \n";
	print<<HTMLOUT;
	<html>
	<head> The files listed in directory: $dir</head>
	<body>
	
	foreach(@files){
		<p>$_</p>
	}
	</body></html>
HTMLOUT
	
}
#lisfiles();

#017 Hangman Game

sub Hangman{
	my %sw;my $file;
	getopts("f:",\%sw);
	$file=$sw{f} if defined $sw{f} or die " No -f Filename sepcified on CLI";
	unless(lc $file eq "hangman.txt"){ die " Didn't find hangman.txt file";}
	open FH,$file;
	my @words=<FH>;
	foreach(@words){chomp $_;}
	my $wordindex= floor rand @words; # used POSIX module for floor| get random word
	my $word=$words[$wordindex]; 
	#$word= join "",(split //,$word);
	#print Dumper $word;
	my $wordlen=length $word;
	print "\n Start Guessing the $wordlen lettered Fruit Letter by Letter ! \n";
	my $turns=3;
	print "\n << You have $turns turns to guess the word >> \n\n";
	my $guessedword="";
	my @word=split //,$word; # array helps in checking duplicate entry of letter
	my $i=0;
	while($turns>0 && $wordlen>0){
		print " \nEnter your guess \n";
		my $gues=<STDIN>;
		chomp $gues;
		if(lc $word[$i] eq lc $gues)
		{
			$wordlen-=1;
			$guessedword.=$gues." ";
			print " < Correct Guess >\n";
			print " Your word is : $guessedword \n";
			print " More $wordlen letters to go \n";
			splice @word,$i,1,""; # removing guessd letters to avoid match of duplicates
			$i+=1;
		}
		else{
			$turns-=1;
			print " < Incorrect Guess $guessedword > !!!\n You have $turns chances remaining\n";
			
		}
	}
	print " \nHangman Lost > Word was $word " if $turns==0 && $wordlen>0;
	print " \nGame Success >> $word << guessed with $turns attempts remaining  " if $wordlen==0;
	
}
#Hangman();
sub ballot_custom_sort{
	my $aplha_file="english_alphas.txt";
	open FH,$aplha_file or die " >> english_alphas.txt not found <<";
	my @alphabets=<FH>;
	close FH;
	my @nums=(1..26); # to use these numbers for custom sort reference => sort on these nums as keys
	my %alpha_num_hash;
	foreach(@alphabets){
		regenerate: my $n=ceil rand 26;
		goto regenerate if defined $alpha_num_hash{$n}; # geenerating unique alpha ids
		chomp $_;
		$alpha_num_hash{$n}=$_; 
	}
	my @keyarr=keys %alpha_num_hash;
	my %sw;
	getopts("f:",\%sw);
	my @persons;
	if(defined $sw{f}){my $ballotfile=$sw{f};open FH,$ballotfile;@persons=<FH>;close FH}
	else{ 
	print "\n --> File <-f ballot.txt> not specified <-- \n Please enter the ballot entries on Command Line and press ctrl+C when done -- \n\n";
	@persons=read_cli();}
	my %person_sorting_rank;
	my @person_sorting_rank;
	foreach(@persons){
		chomp $_;
		my $person=$_;
		my $id_sum=0;
		my @arr=split //,$_; #splitting the name of each person
		foreach(@arr){
			my $alpha=$_;
			foreach(@keyarr){ #searching for the character and its sort id i.e. key 
				if($alpha_num_hash{$_} eq $alpha){
					$id_sum+=$_;
				}
			}
		}
		my $person_rank=$id_sum; # the rank of each person which decides the sorting order
		my $person_ranked=$person_rank.$person;
		push @person_sorting_rank,$person_ranked;
		$person_sorting_rank{$person_rank}=$person;
	}
	print "\n >>> The ballot names with random custom sorting <<< \n\n";
	#print ucfirst $person_sorting_rank{$_},"==",$_,"\n" foreach sort {$a <=> $b} keys %person_sorting_rank;
	#print ucfirst "-- ",$person_sorting_rank{$_},"\n" foreach sort {$a <=> $b} keys %person_sorting_rank;
    # >>>decided to store rank in an array as hash cannot store duplicate rank or names.
	#print Dumper sort @person_sorting_rank;
	foreach( sort @person_sorting_rank){
		$_=~s/[0-9]+//;
		print "-- ",ucfirst $_,"\n";
	}
	
	sub read_cli{
		my @arr;
		unless($SIG{INT}){
		while(<>){chomp $_;push @arr,$_}}
		return @arr;
	}
}
ballot_custom_sort();

