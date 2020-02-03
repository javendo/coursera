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
        if json_line.has_key("text") and json_line.has_key("place") and json_line["place"] != None and json_line["place"]["country_code"] == "US":
            yield (json_line["place"]["full_name"][-2:], json_line["text"])

def read_worlds_in_text(text):
    #return re.sub("[\.\t\:;\.\"\n\r\!\#']", "", text.encode("utf-8")).split(" ")
    return re.split("\W+", text.encode("utf-8").replace("'", ""))

def main():
    sent_file = open(sys.argv[1])
    tweet_file = open(sys.argv[2])
    sentiment_dict = build_sentiment_dict(sent_file)
    states = {}
    for tweet in read_tweets(tweet_file):
        sentiment = 0
        for world in read_worlds_in_text(tweet[1]):
            world_lower = world.lower()
            sentiment += sentiment_dict.get(world_lower, 0)
        states[tweet[0]] = states.get(tweet[0], 0) + sentiment

    print(max(states, key=states.get))

if __name__ == '__main__':
    main()
