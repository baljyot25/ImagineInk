from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_mysqldb import MySQL
from flask_session import Session
import MySQLdb.cursors
import re
from datetime import datetime
import sys
from flask_cors import CORS
from datetime import timedelta
app = Flask(__name__)
app.secret_key = "apple"
CORS(app)  # This will enable CORS for all routes

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'password'
app.config['MYSQL_DB'] = 'imaginink'
mysql = MySQL(app)


@app.route('/customer/login', methods=['POST','GET'])
def customer_login():
    user_details = request.json
    print(user_details)
    for key, value in user_details.items():
        print(f"{key}: {value}")
    # value = data.get('key')
    email_id = user_details['email']
    # print(email_id)
    password = user_details['password']
    query = f"""
        SELECT * FROM ImaginInk.user WHERE email_id = '{email_id}' AND password = '{password}' AND account_type = 'customer';
    """

    cur = mysql.connection.cursor()
    cur.execute(query)
    user = cur.fetchone()
    cur.close()
    if user:
        if user[3] == 'deleted':
            return {"status": "account has been deleted"}
        session['user_id'] = user[0]
        user_id = user[0]
        query = f"""
            SELECT * FROM ImaginInk.customer WHERE customer_id = {user_id};
        """
        cur = mysql.connection.cursor()
        cur.execute(query)
        customer = cur.fetchone()
        query = f"""
            SELECT * FROM ImaginInk.user WHERE user_id = {user_id};
        """
        cur.execute(query)
        user = cur.fetchone()
        cur.close()
        user_details = {
            "address": customer[1],
            "username": user[3],
            "email_id": user[1],
            "full_name": user[5],
            "payment_method": user[9],
            "registration_date": user[6],
        }
        return {"status": "successfully logged in", "user": user_details}
    else:
        return {"status": "invalid credentials"}
    
if __name__ == '__main__':
    # app.run(host='localhost', port=8000, debug=True)sz
    app.run(port=8000)