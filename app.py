from __future__ import print_function
from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re
from datetime import datetime
import sys

app = Flask(__name__)

app.secret_key = "apple"

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'password'
app.config['MYSQL_DB'] = 'imaginink'

mysql = MySQL(app)

@app.route('/', methods=['GET', 'POST'])
def index():
    print("Hello World!", file=sys.stderr)
    return render_template('index.html')

@app.route('/search_bar_suggestions', methods=['POST'])
def get_suggestions():
    search_text = request.json['searchText']
    cursor = mysql.connection.cursor()
    if search_text == "":
        cursor.execute("""SELECT tag_name FROM ImaginInk.tag
                          ORDER BY usage_count DESC
                          LIMIT 5;""")
    else:
        cursor.execute(f"""SELECT tag_name FROM ImaginInk.tag
            WHERE (SELECT LOCATE("{search_text}", tag_name, 1)) > 0
            ORDER BY usage_count DESC LIMIT 5;""")
    tags = [row[0] for row in cursor.fetchall()]
    cursor.close()
    print(tags, file=sys.stderr)
    return jsonify(tags)


app.run(host='localhost', port=5000, debug=True)