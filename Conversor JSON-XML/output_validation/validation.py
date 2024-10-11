#apt-get install python3-jsonschema
import json
from jsonschema import Draft7Validator, FormatChecker, exceptions

xFileName = "ejemplo.json"
sFileName = "estandar.schema.json"

with open(xFileName, 'r') as xFp:
    with open(sFileName, 'r') as sFp:
        v = Draft7Validator(schema=json.load(sFp), format_checker=FormatChecker())
        try:
            v.validate(json.load(xFp))
            print("ok")
        except exceptions.ValidationError as e:
            print (str(e))

