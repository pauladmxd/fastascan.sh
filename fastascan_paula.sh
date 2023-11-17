
#Folder x where to search
if [[ -n $1 ]]; then

    fasta_files=$(find $1 \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \) );
    folder=$1;
    
else
    fasta_files=$(find . \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \)  );
    folder="the current folder";
fi;

echo -e "\nWelcome to FastaScan by Paula Delgado\n";

echo -e "------------Summary folder report-----------\n"

echo "Your desired folder is" $folder

#Number of lines

if [[ -n $2 ]];then

	nlines=$2;
else
	nlines=0;
fi;
 
#How many files are in the folder

number_files=$(echo "$fasta_files" | wc -l)
echo "### Number of fasta files:$number_files";

#Unique IDs

total_unique_ID=0;

for file in $fasta_files; do
    unique_ID=$(awk '/^>/ {print $1}' "$file" | sort | uniq | wc -l)
    total_unique_ID=$((unique_ID + total_unique_ID))
done;

echo "### Total Unique ID: $total_unique_ID" ;

#For each file
echo -e "\n------------Single file report-----------\n"

for file in $fasta_files; do

	file_name=$(basename "$file");

	echo -e "### File name: $file_name\n";

	if [[ -s $file ]]; then # empty or not

		if [[ -h $file ]]; then #Symlink or not
		
			echo "> It is a symlink that links to" $(readlink $file)
	
		else
		
			echo "> It is not a link"
		
		fi;
		
		number_sequences=$(grep -c ">" $file); #number of sequences found in the file
	
		echo "> Number of sequences: $number_sequences";
	
	else
	
		echo "> The file is empty"
	
	fi;
	
	echo -e "\n"; # empty line
	
done;
