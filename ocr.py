import easyocr

reader = easyocr.Reader(['ko', 'en'])

result = reader.readtext('test.jpg', detail=0)
print(result)