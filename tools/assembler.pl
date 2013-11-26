#!/usr/bin/perl

%MCODE = (	ADDI	=> '00000',
				SUBI	=> '00001',
				MULTI	=> '00010',
				DIVI	=> '00011',
				ANDI	=> '00100',
				ORI	=> '00101',
				XORI	=> '00110',
				ROLI	=> '01000',
				SLLI	=> '01001',
				SRLI	=> '01010',
				SRAI	=> '01011',
				LBI	=> '01100',
				SLBI	=> '01101',
				STI	=> '01110',
				LDI	=> '01111',
				ADD	=> '10000',
				SUB	=> '10000',
				MULT	=> '10000',
				DIV	=> '10000',
				AND	=> '10001',
				OR		=> '10001',
				XOR	=> '10001',
				NOT	=> '10001',
				ROL	=> '10010',
				SLL	=> '10010',
				SRL	=> '10010',
				SRA	=> '10010',
				SEQ	=> '10011',
				SLT	=> '10011',
				SLE	=> '10011',
				SCO	=> '10011',
				BEQZ	=> '10100',
				BNEZ	=> '10101',
				BLTZ	=> '10110',
				BGEZ	=> '10111',
				J		=> '11000',
				JR		=> '11001',
				JAL	=> '11010',
				JALR	=> '11011',
				HALT	=> '1110000000000000',
				NOP	=> '1110100000000000',
				ST		=> '11110',
				LD		=> '11111');

$addr=0;
while(<>){						# go through every line in source file 
	#push(@source,$_);
	# pre-process
	if(/(;.+)/){				# comments
		#printf"%s\n",$1;
		s/;.+//;					# remove comment
	}
	if(/(\w+):/){				# word followed by a colon, meaning label
		$label{$1}=$addr;
		s/\w+://;				# remove labels
	}
	if(/(MACRO)\s+(\w+)\s+(#?\w+)/){	# found a macro
		$macro{$2}=$3;
	}
	elsif(/[A-Z]+/){			# not a macro, found digits or an instruction
		push(@source,$_);
		$addr++;
	}
}
print"**** MACROS ****\n";
foreach $1 (keys(%macro)){
	printf"%s = %s\n",$1,$macro{$1};
	foreach (@source){
		#printf"%s",$_;
		#printf"%s\n",$1;
		s/$1/$macro{$1}/;			# replace macro label with value
		#printf"%s",$_;
	}
}
print"\n**** LABEL LIST ****\n";
foreach $1 (keys(%label)){
	#printf "%s",$1;
	printf "%-10s%03d\n",$1,$label{$1};
	foreach (@source){
		#printf"%s",$_;
		#printf"%s\n",$1;
		s/$1/#$label{$1}/;			# replace label with address
		#printf"%s",$_;
	}
}

$addr=0;
print "\n**** MACHINE PROGRAM ****\n";
foreach (@source){
	$line = $_;
	#s/\w+://;
	if(/(ADDI|SUBI|MULTI|DIVI|ANDI|ORI|XORI|ROLI|SLLI|SRLI|SRAI)\s+R(\d),\s+R(\d),\s+#(-?\d+)/){
		# finds ADDI Rd, Rs, #immediate, etc.
		if($4 < 0){		# negative immediate
			$num = 31+$4+1;
			printf"%03d:%s%03b%03b%5b\t$line",$addr++,$MCODE{$1},$3,$2,$num;
		}
		else{
			printf"%03d:%s%03b%03b%05b\t$line",$addr++,$MCODE{$1},$3,$2,$4;
		}
	}
	elsif(/(LBI|SLBI|STI|LDI)\s+R(\d),\s+#(-?\d+)/){
		# finds LBI Rs, #immediate, etc.
		if($3 < 0){		#negative immmediate
			$num = 255+$3+1;
			printf"%03d:%s%03b%8b\t$line",$addr++,$MCODE{$1},$2,$num;
		}
		else{
			printf"%03d:%s%03b%08b\t$line",$addr++,$MCODE{$1},$2,$3;
		}
	}
	elsif(/(ADD|AND|ROL|SEQ)\s+R(\d),\s+R(\d),\s+R(\d)/){
		# finds ADD Rd, Rs, Rt
		$class = 0;
		printf"%03d:%s%03b%03b%03b%02b\t$line",$addr++,$MCODE{$1},$3,$4,$2,$class;
	}
	elsif(/(MULT|XOR|SRL|SLE)\s+R(\d),\s+R(\d),\s+R(\d)/){
		# finds MULT Rd, Rs, Rt
		$class = 2;
		printf"%03d:%s%03b%03b%03b%02b\t$line",$addr++,$MCODE{$1},$3,$4,$2,$class;
	}
	elsif(/(SUB|OR|SLL|SLT)\s+R(\d),\s+R(\d),\s+R(\d)/){
		# finds SUB Rd, Rs, Rt
		$class = 1;
		printf"%03d:%s%03b%03b%03b%02b\t$line",$addr++,$MCODE{$1},$3,$4,$2,$class;
	}
	elsif(/(DIV|SRA|SCO)\s+R(\d),\s+R(\d),\s+R(\d)/){
		# finds DIV Rd, Rs, Rt
		$class = 3;
		printf"%03d:%s%03b%03b%03b%02b\t$line",$addr++,$MCODE{$1},$3,$4,$2,$class;
	}
	elsif(/(NOT)\s+R(\d),\s+R(\d)/){
		# finds NOT Rd, Rs
		printf"%03d:%s%03b000%03b11\t$line",$addr++,$MCODE{$1},$3,$2;
	}
	elsif(/(BEQZ|BNEZ|BLTZ|BGEZ|JR|JALR|ST|LD)\s+R(\d),\s+#(-?\d+)/){
		# finds BEQZ Rd, Rs, #immediate
		if($3 < 0){		# negative immediate
			$num = 255+$3+1;
			printf"%03d:%s%03b%8b\t$line",$addr++,$MCODE{$1},$2,$num;
		}
		else{
			printf"%03d:%s%03b%08b\t$line",$addr++,$MCODE{$1},$2,$3;
		}
	}
	elsif(/(J|JAL)\s+#(-?\d+)/){
		# finds J displacement
		if($2 < 0){		# negative displacement
			$num = 2047+$2+1;
			printf"%03d:%s%11b\t$line",$addr++,$MCODE{$1},$num;
		}
		else{
			printf"%03d:%s%011b\t$line",$addr++,$MCODE{$1},$2;
		}
	}
	elsif(/(ST|LD)\s+R(\d),\s+R(\d),\s+#(-?\d+)/){
		# finds ADDI Rd, Rs, #immediate, etc.
		if($4 < 0){		# negative immediate
			$num = 31+$4+1;
			printf"%03d:%s%03b%03b%5b\t$line",$addr++,$MCODE{$1},$3,$2,$num;
		}
		else{
			printf"%03d:%s%03b%03b%05b\t$line",$addr++,$MCODE{$1},$3,$2,$4;
		}
	}
	elsif(/([A-Z]+)/){
		printf"%03d:%04s\t$line",$addr++,$MCODE{$1};
	} else{
		print "\t\t$line";
	}
}

# code modified from http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&ved=0CDQQFjAB&url=http%3A%2F%2Fwww.cs.hiroshima-u.ac.jp%2F~nakano%2Fwiki%2Fwiki.cgi%3Faction%3DATTACH%26page%3DCourse%2BMaterials%26file%3Demb5.pdf&ei=JqR6Us-4LKKGyQHzg4DgDA&usg=AFQjCNHGQrfRnJ6dLqdD7QuH7fIAoFCU5g&sig2=wCGjvORTyfGyGsF46dvG9g&bvm=bv.55980276,d.aWc&cad=rja
