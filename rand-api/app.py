from flask import Flask
from random import randint

app = Flask(__name__)

@app.route('/random')
def get_random_numberS():
    numbers = [randint(0, 100) for _ in range(10)]
    response = {
        "data": {"random_number": numbers},
        "message": "success"
    }
    return response
