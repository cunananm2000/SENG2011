from algos import simpleLinearSearch

class enum(object):
    def __init__(self):
        self._keys = []

    def addKey(self,key):
        self._keys.append(key)

    def getIndex(self,key):
        return simpleLinearSearch(self._keys,key)

    def getSize(self):
        return len(self._keys)