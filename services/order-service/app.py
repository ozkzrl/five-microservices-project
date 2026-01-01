import requests
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/orders")
def get_orders():
    users = requests.get("http://user-service:5000/users").json()
    products = requests.get("http://product-service:5000/products").json()

    return jsonify({
        "user": users[0],
        "product": products[0]
    })

@app.route("/health")
def health():
    return {"status": "order-service ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
