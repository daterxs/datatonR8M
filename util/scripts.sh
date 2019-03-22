

# List content
7z l tweets_all.jsonl.7z 

# Extract
7z e tweets_all.jsonl.7z 

# Niv magic trick to convert jsonl to csv
cat tweets_8m.jsonl | jq -M '. as $in 
| reduce leaf_paths as $path ({};
     . + { ($path | map(tostring) | join(".")): $in | getpath($path) }) | to_entries | map(.key), map(.value) | @csv' | sed s/'\\\"'/'"'/g > tweets_8m.csv

