from flask import Flask, render_template
import json
from datetime import datetime

app = Flask(__name__)

def load_branch_data():
    try:
        with open('branch_data.json', 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        return []

@app.route('/')
def dashboard():
    branch_data = load_branch_data()
    # Sort data by timestamp (most recent first)
    branch_data.sort(key=lambda x: datetime.strptime(x['timestamp'], '%Y-%m-%d %H:%M:%S'), reverse=True)
    return render_template('dashboard.html', branch_data=branch_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
