#!/bin/bash

# Define the file type of each SMS record
SEARCH_TYPE="*.xml"

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "No arguments provided. Usage: ./mass_extraction.sh <directory_of_xmls>"
    exit 1
fi

# Get the first command line argument (folder of records)
SEARCH_DIR="$1"

# Loop over all .xml files in the specified directory
find "$SEARCH_DIR" -type f -name "$SEARCH_TYPE" | while read -r xml_file; do
    # Get the base name of the XML file (without the .xml extension)
    base_name=$(basename "$xml_file" .xml)
    
	# Store the directory path
	directory=$(readlink -f "$base_name")
	directoryRelative=$(realpath -s --relative-to="." "$directory")
	
	# Remove directory if it already exists
	# Create a directory for the output files if not
	if [ -d "$directory" ]; then
		echo "Directory exists. Deleting..."
		rm -rf "$directory"
		echo "Directory deleted."
	else
		echo "Directory does not exist."
		mkdir "$directory"
		echo "Directory created."
	fi

    # Run the sbrparser script on the XML file
    ./sbrparser -d "$directory" "$xml_file"
    
    # Check if sbrparser ran successfully
    if [ $? -eq 0 ]; then
		echo "Success: finished parsing $xml_file"
		
		# Create a tar archive named after the XML file (without the .xml)
        tar -cf "${base_name}.tar" "${directoryRelative}"
		
		if [ $? -eq 0 ]; then
			echo "Success: tarball created, removing directory"
			rm -r "$directory"
			echo "Success: Directory removed"
		else
			echo "Error: couldn't create tarball of $directory"
		fi
    else
        echo "Error: sbrparser failed on $xml_file"
    fi
done
