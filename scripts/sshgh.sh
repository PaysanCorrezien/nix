current_url=$(git config --get remote.origin.url)
echo "Current URL: $current_url"

if [[ $current_url == https://github.com/* ]]; then
	new_url=$(echo $current_url | sed 's|https://github.com/|git@github.com:|')
	git remote set-url origin "$new_url"
	echo "Updated URL: $new_url"
else
	echo "No change needed."
fi
