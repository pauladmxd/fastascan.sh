
echo -e "\nWelcome to FastaScan\n"

#Folder x where to search
if [[ -n $1 ]]; then

    fasta_files=$(find $1 \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \) )
    folder=$1;
    
else
    fasta_files=$(find . \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \)  )
    folder="the current folder";
fi

echo -e "------------Summary folder report-----------\n"

echo "Your desired folder is" $folder

#Number of lines

if [[ -n $2 ]];then

	nlines=$2
else
	nlines=0
fi
 
#How many files are in the folder

number_files=$(echo "$fasta_files" | wc -l)
echo "### Number of fasta files:" $number_files

#Unique IDs

total_unique_ID=0;

for file in $fasta_files; do
    unique_ID=$(awk '/^>/ {print $1}' "$file" | sort | uniq | wc -l)
    total_unique_ID=$((unique_ID + total_unique_ID))
done;

echo "### Total Unique ID: $total_unique_ID" 

#For each file do...
echo -e "\n------------Single file report-----------\n"

for file in $fasta_files; do

	file_name=$(basename "$file")

	echo -e "### File name: $file_name\n"
	
#It the file empty or not
	if [[ -s $file ]]; then 
	
#Extra points. Aminoacid or nucleotides
		
		if grep -v '>' "$file" | grep -qi [RDQEHILKMFPSWYV]; then
		
			echo "-> Content: Amino acid sequences"
			
		else
		
			echo "-> Content: Nucleotide sequences"
		fi

#Is it a Symlink or not
		
		if [[ -h $file ]]; then 
		
			echo "-> It is a symlink that links to" $(readlink $file)
	
		else
		
			echo "-> It is not a link"
		
		fi;
		
        
#Number of sequences found in the file
		
		number_sequences=$(grep -c ">" $file)
	
		echo "-> Number of sequences: $number_sequences"
		
#Lenght of the sequences without gaps
		
		total_length_seq=$(awk '/^[^>]/ { gsub("-", ""); gsub("\n", ""); total += length($0) } END { print total }' $file) 

		echo "-> Total sequences length: $total_length_seq"

#Print according to the number of lines
		
		if [[ $nlines != 0 ]]; then
			
			lines=$(cat $file | wc -l)
		
			if [[ $lines -gt $((2 * $nlines)) ]]; then
			echo -e "-> Showing the first and last $nlines lines: \n"
			head -n $nlines $file
			echo " ... ";
			tail -n $nlines $file
			
			else 
			echo -e "-> Showing the whole file: \n"
			cat $file
			
			fi;
			
		fi;

	else
	
		echo "-> The file is empty"
	
	fi;
	
	echo -e "\n" # empty line to separate
	
done;
