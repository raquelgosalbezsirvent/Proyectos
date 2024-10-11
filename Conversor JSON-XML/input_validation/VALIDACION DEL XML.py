#apt-get install python3-lxml
from lxml import etree

xFileName = "ejemplo.xml"
sFileName = "modelo.xsd"

try:
    xDoc = etree.parse(xFileName)
    sDoc = etree.parse(sFileName)
    schema = etree.XMLSchema(sDoc)
    schema.assertValid(xDoc)
    print ("ok")
except etree.XMLSyntaxError as e:
    print (str(e))
except etree.XMLSchemaParseError as e:
    print (str(e))
except etree.DocumentInvalid as e:
    print (str(e))
