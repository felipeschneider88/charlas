import requests

url = "http://localhost:5292/api/Mascota"

payload = "{\r\n  \"id\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\",\r\n  \"nombre\": \"string\"\r\n}"
headers = {
    'content-type': "application/json",
    'cache-control': "no-cache",
    'postman-token': "252efac1-b706-15f3-9167-b780f88d1549"
    }

response = requests.request("GET", url, data=payload, headers=headers)

print(response.text)