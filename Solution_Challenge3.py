def traverse_nested_json(njson, jkey):
    if isinstance(njson, dict):
        return extract(njson, jkey, 0, [])
    else:
            return "This is not a nested object" 

def extract(njson, jkey, count, newstring):
    key = jkey[count]
    if count + 1 < len(jkey):
        if key in njson.keys():
            extract(njson.get(key), jkey, count + 1, newstring)
        else:
            newstring.append(None)

    if count + 1 == len(jkey):
        #print("last iteration" + str(count +1))
        try:
            newstring.append(njson.get(key, "Item doesn't exist"))
        except Exception as e:
            print ("You have reached the end of object")
   
    return newstring

json_key={"x":{"y":{"z":{"a"}}}}
traverse_nested_json(json_key, ['x','y'])
