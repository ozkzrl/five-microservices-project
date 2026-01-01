from flask import Flask, jsonify

app = Flask(__name__)

products = [
    {"id": 1, "name": "Laptop"},
    {"id": 2, "name": "Mouse"}
]

@app.route("/products")
def get_products():
    return jsonify(products)

@app.route("/health")
def health():
    return {"status": "product-service ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
