import urllib
import json

for i in range(1,11):
    response = urllib.urlopen("http://search.twitter.com/search.json?q=microsoft&page=%s" % (i))
    json_response = json.load(response)
    for results in json_response["results"]:
        print results["text"].replace("\n", " ")
