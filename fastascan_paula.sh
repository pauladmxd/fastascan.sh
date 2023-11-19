
echo -e "\nWelcome to FastaScan\n"

#Folder x where to search
if [[ -n $1 ]]; then

    fasta_files=$(find $1 \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \) )
    folder=$1;
    
else
    fasta_files=$(find . \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \)  )
    folder="the current folder";
fi

echo -e "---------------------------------------- FOLDER REPORT -----------------------------------------\n"

echo "Your desired folder is" $folder

#Number of lines

if [[ -n $2 ]];then
	nlines=$2
else
	nlines=0
fi
 
#How many files are in the folder

if [ -z "$fasta_files" ]; then # without that condition, when there is no files it still counts at least 1 line and appears 1 file
    number_files=0
    echo -e "!!! There is no fasta or fa files in that folder, or doesn't exist, try again\n"
	exit # we dont want to print the table without files
else
    number_files=$(echo "$fasta_files" | wc -l)
    echo "### Number of fasta files:" $number_files
fi

#Unique IDs

total_unique_ID=0;

for file in $fasta_files; do
    unique_ID=$(awk '/^>/ {print $1}' "$file" | sort | uniq | wc -l)
    total_unique_ID=$((unique_ID + total_unique_ID))
done;

echo "### Total Unique ID: $total_unique_ID" 

#For each file do...

echo -e "\n---------------------------------------- SUMMARY TABLE -----------------------------------------\n"

printf "%-40s %-15s %-15s %-15s %-15s\n" "FILE NAME" "CONTENT" "SYMLINK" "Nº SEQUENCES" "LENGTH"
echo 

for file in $fasta_files; do
    file_name=$(basename "$file")
    
    if [[ -s $file ]]; then 
        if grep -v '>' "$file" | grep -qi [RDQEHILKMFPSWYV]; then
            type="Aminoacidic"
        else
            type="Nucleotidic"
        fi
        
        if [[ -h $file ]]; then 
            link="Yes"
        else
            link="No"
        fi
        
        number_sequences=$(grep -c ">" $file)
        total_length_seq=$(awk '/^[^>]/ { gsub("-", ""); gsub("\n", ""); total += length($0) } END { print total }' $file) 
	else
	link="-"
	total_length_seq="-"
	number_sequences="-"
	type="Empty"
	
    fi
    
    printf "%-40s %-15s %-15s %-15s %-15s\n" "$file_name" "$type" "$link" "$number_sequences" "$total_length_seq"
    
    echo # empty line to separate

done;

# Printing based on nlines

if [[ $nlines != 0 ]]; then
    echo -e "\n------------------------------- PRINTING ACCORDING TO Nº OF LINES ----------------------------------\n"
    for file in $fasta_files; do
        if [[ -s $file ]]; then
            echo -e "### File name: $(basename "$file")"
            lines=$(wc -l < $file)
            if [[ $lines -gt $((2 * $nlines)) ]]; then
                echo -e "-> Showing the first and last $nlines lines: "
                head -n $nlines $file
                echo " ... "
                tail -n $nlines $file
            else 
                echo -e "-> Showing the whole file: "
                cat $file
            fi
            echo  # empty line to separate
        fi
    done
fi

