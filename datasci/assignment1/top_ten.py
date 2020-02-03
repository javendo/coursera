import sys
import json
import re

def read_tweets(fp):
    for line in fp.readlines():
        json_line = json.loads(line)
        if json_line.has_key("entities") and json_line["entities"].has_key("hashtags"):
            yield json_line["entities"]["hashtags"]

def main():
    tweet_file = open(sys.argv[1])
    global_worlds_frequency = {}
    for tweet in read_tweets(tweet_file):
        for hashtags in tweet:
            text = hashtags["text"]
            global_worlds_frequency[text] = global_worlds_frequency.get(text, 0) + 1

    sorted_ranking_worlds = sorted(global_worlds_frequency.iteritems(), key=lambda x:-x[1])[:10]

    for ranking in sorted_ranking_worlds:
        print("%s %f" % (ranking[0], float(ranking[1])))

if __name__ == '__main__':
    main()
