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
    return re.sub("[\.\t\:;\.\"\n\r\!\#']", "", text.encode("utf-8")).split(" ")
    #return re.split("\W+", text.encode("utf-8").replace("'", ""))

def main():
    sent_file = open(sys.argv[1])
    tweet_file = open(sys.argv[2])
    sentiment_dict = build_sentiment_dict(sent_file)
    global_worlds_not_in_sentiment = {}
    for text in read_tweets(tweet_file):
        worlds_not_in_sentiment = []
        sentiment = 0
        for world in read_worlds_in_text(text):
            world_lower = world.strip()
            if sentiment_dict.has_key(world_lower):
                sentiment += sentiment_dict[world_lower]
            else:
                worlds_not_in_sentiment.append(world_lower)

        for world in worlds_not_in_sentiment:
            global_worlds_not_in_sentiment[world] = global_worlds_not_in_sentiment.get(world, 0) + sentiment

    global_worlds_not_in_sentiment.pop("");

    for (k, v) in global_worlds_not_in_sentiment.iteritems():
        if v != 0:
            print("%s %s" % (k, v))

if __name__ == '__main__':
    main()
