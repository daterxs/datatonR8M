
cd ~/git/data_9m_twitter/data/
# List content
7z l tweets_all.jsonl.7z 

# Extract
7z e tweets_all.jsonl.7z 

# Lines of jsonla
cat  ~/git/data_9m_twitter/data/tweets_all.jsonl | wc -l
# 1674296 20 segundos en ejecucion

# Niv magic trick to convert jsonl to csv
cat tweets_8m.jsonl | jq -M '. as $in 
| reduce leaf_paths as $path ({};
     . + { ($path | map(tostring) | join(".")): $in | getpath($path) }) | to_entries | map(.key), map(.value) | @csv' | sed s/'\\\"'/'"'/g > tweets_8m.csv

