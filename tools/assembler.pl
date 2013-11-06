#!/usr/bin/perl

%MCODE = (	ADDI	=> '00000sssdddiiiii',
				SUBI	=> '00001sssdddiiiii',
				MULTI	=> '00010sssdddiiiii',
				DIVI	=> '00011sssdddiiiii',
				ANDI	=> '00100sssdddiiiii',
				ORI	=> '00101sssdddiiiii',
				XORI	=> '00110sssdddiiiii',
				ROLI	=> '01000sssdddiiiii',
				SLLI	=> '01001sssdddiiiii',
				SRLI	=> '01010sssdddiiiii',
				SRAI	=> '01011sssdddiiiii',
				LBI	=> '01100sssdddiiiii',
				SLBI	=> '01101sssiiiiiiii',
				STI	=> '01110sssiiiiiiii',
				LDI	=> '01111sssiiiiiiii',
				ADD	=> '10000ssstttddd00',
				SUB	=> '10000ssstttddd01',
				MULT	=> '10000ssstttddd10',
				DIV	=> '10000ssstttddd11',
				AND	=> '10001ssstttddd00',
				OR		=> '10001ssstttddd01',
				XOR	=> '10001ssstttddd10',
				NOT	=> '10001sssxxxddd11',
				ROL	=> '10010ssstttddd00',
				SLL	=> '10010ssstttddd01',
				SRL	=> '10010ssstttddd10',
				SRA	=> '10010ssstttddd11',
				SEQ	=> '10011ssstttddd00',
				SLT	=> '10011ssstttddd01',
				SLE	=> '10011ssstttddd10',
				SCO	=> '10011ssstttddd11',
				BEQZ	=> '10100sssiiiiiiii',
				BNEZ	=> '10101sssiiiiiiii',
				BLTZ	=> '10110sssiiiiiiii',
				BGEZ	=> '10111sssiiiiiiii',
				J		=> '11000ddddddddddd',
				JR		=> '11001sssiiiiiiii',
				JAL	=> '11010ddddddddddd',
				JALR	=> '11011sssiiiiiiii',
				HALT	=> '11100xxxxxxxxxxx',
				NOP	=> '11101xxxxxxxxxxx',
				ST		=> '11110sssiiiiiiii',
				LD		=> '11111dddiiiiiiii');

$addr=0;
while(<>){
	push(@source,$_);
	if(/(\w+):/){
		$label{$1}=$addr;
		s/\w+://;
	}
	if(/-?\d+|[A-Z]+/){
		$addr++;
	}
}

print"*** LABEL LIST ***\n";
foreach $l (sort(keys(%label))){
	printf "%-8s%03X\n",$l,$label{$l};
}

$addr=0;
print "\n*** MACHINE PROGRAM ***\n";
foreach (@source){
	$line = $_;
	s/\w+://;
	if(/([A-Z]+)/){
		printf"%03X:%04s\t$line",$addr++,$MCODE{$1};
	} else{
		print "\t\t$line";
	}
}

# code modified from http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&ved=0CDQQFjAB&url=http%3A%2F%2Fwww.cs.hiroshima-u.ac.jp%2F~nakano%2Fwiki%2Fwiki.cgi%3Faction%3DATTACH%26page%3DCourse%2BMaterials%26file%3Demb5.pdf&ei=JqR6Us-4LKKGyQHzg4DgDA&usg=AFQjCNHGQrfRnJ6dLqdD7QuH7fIAoFCU5g&sig2=wCGjvORTyfGyGsF46dvG9g&bvm=bv.55980276,d.aWc&cad=rja
