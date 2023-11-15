
#Folder x where to search
if [[ -n $1 ]];
then
    fasta_files=$(find $1 \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \) );
    folder=$1;
else
    fasta_files=$(find . \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \)  );
    folder="the current folder";
fi;

#echo $fasta_files;

echo "Your desired folder is" $folder

#Number of lines
if [[ -n $2 ]];
then
	nlines=$2;
else
	nlines=0;
 fi;
 
#How many files there are

echo "Number of fasta files:" $(echo "$fasta_files" | wc -l);

#Unique IDs

total_unique_ID=0;

for file in $fasta_files; do
    unique_ID=$(awk '/^>/ {print $1}' "$file" | sort | uniq | wc -l)
    total_unique_ID=$((unique_ID + total_unique_ID))
done;

echo "Unique identifiers:" $total_unique_ID

#For each file

for file in $fasta_files; do
   if [[ $file -s ]]; then



   else 
		 echo The file $file is empty;
fi; done;
