from flask import Flask
from time import time

app = Flask(__name__)

@app.route('/time')
def get_current_time():
    timestamp = str(int(time()))
    response = {
        "data": {"unix_timestamp": timestamp},
        "message": "success"
    }
    return response
