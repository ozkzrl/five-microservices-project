from flask import Flask, jsonify

app = Flask(__name__)

users = [
    {"id": 1, "name": "Ali"},
    {"id": 2, "name": "Ayşe"}
]

@app.route("/users")
def get_users():
    return jsonify(users)

@app.route("/health")
def health():
    return {"status": "user-service ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
