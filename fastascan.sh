
echo -e "\nWelcome to FastaScan\n"  # -e in echo command enables the interpretation of backslash escape sequences "\"
									# It allows formatting the output by inserting special characters or controlling
									# the cursor position, in this script it is used to print \n that represents a 
									# newline character and helps to make the output easier or more elegant to see.
								
## Folder x where to search

if [[ -n $1 ]]; then     # If a parameter is provided ($1), set fasta_files as the found .fa and .fasta files in the specified directory.
    fasta_files=$(find $1 \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \) )
    folder=$1;			# Set folder as the specified directory.
    
else    # If no parameter is provided, set fasta_files as the found .fa and .fasta files in the current directory as the defect folder.

    fasta_files=$(find . \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \)  )
    folder="the current folder" # Set folder as "the current folder".
fi

if [[ ! -d $folder ]]; then # If the folder doesn't exist or it is not possible to access the code ends here and shows an error message.
    echo "!!! Error: The specified folder '$folder' doesn't exist or is inaccessible."
    exit 
fi

echo -e "-------------------------------------------------------------- FOLDER REPORT ---------------------------------------------------------------\n"

echo -e "Your desired folder is $folder \n"

## Number of lines

if [[ -n $2 ]];then  # If a second parameter is provided ($2), set the number of lines as the specified number.
	nlines=$2
else				# If no second parameter is provided, by defect the number of lines is 0.
	nlines=0
fi
 
## How many files are in the folder

if [ -z "$fasta_files" ]; then # Without that condition, when there is no files or the folder doesnt exist 
							   # it would still count at least 1 line and would appear 1 file in number_files, 
							   # so it checks if there is any file
    number_files=0
    echo -e "!!! There is no fasta or fa files in that folder\n" 
	exit 1 # we dont want to do the rest of the script if there are no files
else
    number_files=$(echo "$fasta_files" | wc -l)     # if there are files it count the lines in the variable 
													# fasta_files that correspond to the number of files 
    echo "### Number of fasta files:" $number_files
fi

## Unique IDs

for file in $fasta_files; do # Loop to iterate on each file of the folder

    unique_ID=$(awk '/^>/ {print $1}' "$file" | sort | uniq | wc -l)    # Extracts lines starting with '>' that will correspond to identifiers, 
																		# sorts them, finds unique occurrences, and count the lines (number of unique identifiers).
																		
    total_unique_ID=$((unique_ID + total_unique_ID)) # Here accumulates the total count of unique identifiers across all files in fasta files. 
done;												 # $((...)) allows to do integer arithmetic calculations


echo "### Total Unique ID: $total_unique_ID" 

## For each file do...

echo -e "\n------------------------------------------------------------- SUMMARY TABLE ----------------------------------------------------------------\n"

printf "%-85s %-15s %-15s %-15s %-15s\n" "FILE NAME" "CONTENT" "SYMLINK" "Nº SEQUENCES" "LENGTH" # The printf command also used in Perl or C, is used to format and print 
																								 # data according to specified formatting instructions. In this case I used it to
echo # empty line																				 # print a table with tabular output and a specific column widths and alignment because 
																								 # if I only used /t it didnt appeared aligned as some names are larger than others.
																								 # The bigger width is set as 85 characters for the first column "file name"
																								 
for file in $fasta_files; do # With this loop we iterate within every file in the variable fasta_files that contains all the fasta or fa files in the desired folder
    
    if [[ -s $file ]]; then	# Checks if the file is not empty
    
		## Aminoacid or nucleotides in the sequence
        if grep -v '>' "$file" | grep -qi [RDQEHILKMFPSWYV]; then # Find the line of the ID and avoid it with -v, then grep -qi does without showing an output and not caring about the 
			type="Aminoacidic"									  # capital letters, then if one of these caracters (Aminoacids) are found in the sequence it is labeled as Aminoacidic type
		else													  # if not, it will be labeled as nucleotidic.								
            type="Nucleotidic"
        fi
        
        ## Link or not
        if [[ -h $file ]]; then  # Checks if it is a link, and label it as Yes (link) or No.
            link="Yes"
        else
            link="No"
        fi
        
        ## Number of sequences in the file
        number_sequences=$(grep -c ">" $file) #grep -c counts the number of matches, ">" represents each sequence
        
        ## Total lenght of the sequences in the file
        total_length_seq=$(awk '/^[^>]/ { gsub("-", ""); gsub("\n", ""); total += length($0) } END { print total }' $file) 
         
			# This command calculates the total length of sequences in the file. It uses awk where:
			# /^[^>]/ matches lines that don't start with >, as it is the ID
			# gsub("-", "") and gsub("\n", "") removes dashes (-) and newline characters (\n) from the lines.
			# total += length($0) accumulates the length of each line of the sequence (without counting dashes or newline characters)
			# END { print total } at the end prints the total length of all sequences and it is stored in the variable total_length_seq.
        
	else # The file is empty so the variables are set as empty or - (nothing) too
		link="-"
		total_length_seq="-"
		number_sequences="-"
		type="Empty"
    fi
    
    printf "%-85s %-15s %-15s %-15s %-15s\n" "$file" "$type" "$link" "$number_sequences" "$total_length_seq" # As the headers of the table, the values are set as the same width 
																											 # to be aligned with the headers and it is done for each file (inside the for loop)
    echo # Empty line to separate

done;

## Printing files based on nlines ($2)

if [[ $nlines != 0 ]]; then # If the number of lines write by the user is not 0 (if no number is written it i s set as 0 by default)

    echo -e "\n----------------------------------------------------- PRINTING ACCORDING TO Nº OF LINES --------------------------------------------------------\n"
    
    for file in $fasta_files; do # Again a loop to iterate within every file in the variable fasta_files with all fasta/fa files. I made 3 times the same loop because 
								 # I wanted to split the information in 3 main parts and print them in that specific order.
    
        echo -e "### File name: $file\n"

        if [[ -s $file ]]; then  # Only do the next if the file is not empty
            lines=$(wc -l < $file) # Count number of lines in the file
            if [[ $lines -gt $((2 * $nlines)) ]]; then # Only if the number of lines is bigger than 2*nlines($2) shows just the first and last nlines
                echo "-> Showing the first and last $nlines lines: "
                head -n $nlines $file
                echo " ... "
                tail -n $nlines $file
            else # If the number of lines in the file is smaller than 2*nlines shows the whole file
                echo "-> Showing the whole file: "
                cat $file
            fi
            echo  # Empty line to separate
            
        else
        echo -e "-> The file is empty\n"
        fi
    done
fi

