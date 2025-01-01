# Input .env file
input_file=".env"

# Output .env.example file
output_file="env.example"

# Process the file, line by line
while IFS= read -r line || [[ -n $line ]]; do
	if [[ "$line" == *"="* ]]; then
		# Handle lines with `=` and keep comments after `#`
		var_name_and_rest="${line%%=*}=" # Keep everything up to '='
		comment="${line#*#}"             # Extract everything after `#`

		# Check if there's a comment
		if [[ "$line" == *"#"* ]]; then
			echo "${var_name_and_rest} #${comment}" >>"$output_file"
		else
			echo "${var_name_and_rest}" >>"$output_file"
		fi
	else
		# Copy lines without `=` as is (e.g., comments, blank lines)
		echo "$line" >>"$output_file"
	fi
done <"$input_file"

echo "Generated $output_file from $input_file"
