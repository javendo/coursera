import sys
import json
import re

def build_sentiment_dict(fp):
    sentiment_dict = {}
    for line in fp.readlines():
        line_array = line.strip().split("\t")
        sentiment_dict[line_array[0]] = int(line_array[1])
    return sentiment_dict

def read_tweets(fp):
    for line in fp.readlines():
        json_line = json.loads(line)
        if json_line.has_key("text"): #and json_line["user"]["lang"] == "en":
            yield json_line["text"]

def read_worlds_in_text(text):
    return re.split("\W+", text.encode("utf-8").replace("'", ""))

def main():
    sent_file = open(sys.argv[1])
    tweet_file = open(sys.argv[2])
    sentiment_dict = build_sentiment_dict(sent_file)
    for text in read_tweets(tweet_file):
        sentiment = 0
        for world in read_worlds_in_text(text):
            world_lower = world.lower()
            sentiment += sentiment_dict.get(world_lower, 0)
        print(sentiment)

if __name__ == '__main__':
    main()
