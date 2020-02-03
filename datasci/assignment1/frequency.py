import sys
import json
import re

def read_tweets(fp):
    for line in fp.readlines():
        json_line = json.loads(line)
        if json_line.has_key("text"): #and json_line["user"]["lang"] == "en":
            yield json_line["text"]

def read_worlds_in_text(text):
    return re.sub("[\.\t\:;\.\"\n\r\!\#']", "", text.encode("utf-8")).split(" ")

def main():
    tweet_file = open(sys.argv[1])
    global_worlds_frequency = {}
    for text in read_tweets(tweet_file):
        for world in read_worlds_in_text(text):
            world_lower = world.strip()
            global_worlds_frequency[world_lower] = global_worlds_frequency.get(world_lower, 0) + 1

    global_worlds_frequency.pop("")

    total_count = sum(global_worlds_frequency.values())

    for (k, v) in global_worlds_frequency.iteritems():
        print("%s %f" % (k, float(v) / total_count))

if __name__ == '__main__':
    main()
