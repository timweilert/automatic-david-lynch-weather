import re
import os

import os 
from pprint import pprint 

files = []
for dirname, dirnames, filenames in os.walk('.'):
    # print path to all subdirectories first.
    for subdirname in dirnames:
        files.append(os.path.join(dirname, subdirname))

    # print path to all filenames.
    for filename in filenames:
        files.append(os.path.join(dirname, filename))


pprint(files)


bad_words = ['-->','</c>'] 

for file in files:

    with open(file) as oldfile, open("{}.txt".format(file), 'w') as newfile:
        for line in oldfile:
            if not any(bad_word in line for bad_word in bad_words):
                newfile.write(line)


    # with open("{}.txt".format(file)) as result:
        # uniqlines = set(result.readlines())
        # with open("{}_sub_out.txt".format(file), 'w') as rmdup:
            # mylst = map(lambda each: each.strip("&gt;&gt;"), uniqlines)
            # print(mylst)
            # rmdup.writelines(set(mylst))