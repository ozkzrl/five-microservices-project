import requests
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/api/users")
def users():
    return requests.get("http://user-service:5000/users").json()

@app.route("/api/products")
def products():
    return requests.get("http://product-service:5000/products").json()

@app.route("/health")
def health():
    return {"status": "gotürüvereceksen gotürü ver"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
