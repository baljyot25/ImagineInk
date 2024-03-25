from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_mysqldb import MySQL
from flask_session import Session
import MySQLdb.cursors
import re
from datetime import datetime
import sys
import os

app = Flask(__name__)

app.secret_key = os.urandom(24)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'banta259'
app.config['MYSQL_DB'] = 'imaginink'
app.config['SESSION_TYPE'] = 'filesystem'

Session(app)

mysql = MySQL(app)


@app.route('/customer/signup', methods=['POST', 'GET'])
def customer_signup():
    user_details = request.json
    email_id = user_details['email_id']
    password = user_details['password']
    username = user_details['username']
    full_name = user_details['full_name']
    payment_method = user_details['payment_method']
    address = user_details['address']
    date = str(datetime.now().date())
    query = f"""
        INSERT INTO ImaginInk.user (email_id, password, username, account_status, full_name, registration_date, last_login_date, account_type, payment_method) VALUES
        ('{email_id}', '{password}', '{username}', 'logged_in', '{full_name}', '{date}', '{date}', 'customer', '{payment_method}');
    """
    print(email_id, file=sys.stderr)
    cur = mysql.connection.cursor()
    flag = True
    try:
        cur.execute(query)
        mysql.connection.commit()
    except (MySQLdb.Error, MySQLdb.Warning) as e:
        flag = False
    cur.close()
    if flag:
        cur = mysql.connection.cursor()
        query = f"""
            UPDATE ImaginInk.customer c
            JOIN ImaginInk.user u ON c.customer_id = u.user_id
            SET address = '{address}'
            WHERE u.email_id = '{email_id}'
            AND u.account_type = 'customer';
        """
        cur.execute(query)
        mysql.connection.commit()
        cur.close()
        return jsonify({"status": "successfully signed up"}), 200
    else:
        return jsonify({"status": "email"}), 400
    
@app.route('/customer/login', methods=['POST'])
def customer_login():
    user_details = request.json
    email_id = user_details['email_id']
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
            return jsonify({"status": "account has been deleted"}), 400
        session['user_id'] = user[0]
        print(f"User id: {session['user_id']}", file=sys.stderr)
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
            "user_id": user_id
        }
        print(session, file=sys.stderr)
        return jsonify({"status": "successfully logged in", "user": user_details}), 200
    else:
        return jsonify({"status": "invalid credentials"}), 200

@app.route('/customer/cart', methods=['POST'])
def customer_cart():
    user_details = request.json
    user_id = user_details['customer_id']
    query = f"""
        SELECT d.design_id, d.title, p.product_id, p.title, ci.quantity, ci.price
        FROM cart_items ci
        JOIN carry c ON ci.cart_id = c.cart_id
        JOIN product p ON ci.product_id = p.product_id
        JOIN design d ON ci.design_id = d.design_id
        WHERE c.customer_id = {user_id};
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    cart = cur.fetchall()
    cur.close()
    design_ids = []
    design_titles = []
    product_ids = []
    product_titles = []
    quantities = []
    prices = []
    total_price = 0
    total_items = 0
    for item in cart:
        design_ids.append(item[0])
        design_titles.append(item[1])
        product_ids.append(item[2])
        product_titles.append(item[3])
        quantities.append(item[4])
        prices.append(item[5])
        total_price += item[5]
        total_items += 1
    return jsonify({"status": "successfully fetched cart",
            "total_price": total_price, 
            "total_items": total_items,
            "design_ids": design_ids,
            "design_titles": design_titles,
            "product_ids": product_ids,
            "product_titles": product_titles,
            "quantities": quantities,
            "prices": prices}), 200

@app.route('/customer/view_designs', methods=['POST'])
def customer_view_designs():
    # if 'user_id' not in session:
    #     print("No user id", file=sys.stderr)
    #     return jsonify({"status": "user not logged in"}), 400
    # user_id = session['user_id']
    # print(user_id, file=sys.stderr)
    query = f"""
        SELECT * FROM design
        WHERE status = 'visible';
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    designs = cur.fetchall()
    cur.close()
    design_ids = []
    design_titles = []
    design_prices = []
    design_description = []
    for design in designs:
        design_ids.append(design[0])
        design_titles.append(design[2])
        design_prices.append(design[6])
        design_description.append(design[3])
    return jsonify({"status": "successfully fetched designs", "design_ids": design_ids, "design_titles": design_titles, "design_prices": design_prices, "design_descriptions": design_description}), 200

@app.route('/customer/view_products', methods=['POST'])
def customer_view_products():
    query = f"""
        SELECT * FROM product;
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    products = cur.fetchall()
    cur.close()
    product_ids = []
    product_titles = []
    product_prices = []
    product_dimensions = []
    for product in products:
        product_ids.append(product[0])
        product_titles.append(product[1])
        product_prices.append(product[3])
    return jsonify({"status": "successfully fetched products", 
            "product_ids": product_ids, 
            "product_titles": product_titles, 
            "product_prices": product_prices}), 200
    
@app.route('/customer/select_design', methods=['POST'])
def customer_select_design():
    if 'user_id' not in session:
        return {"status": "user not logged in"}
    session['design_id'] = request.form['design_id']
    return {"status": "successfully selected design"}


@app.route('/customer/select_product', methods=['POST'])
def customer_select_product():
    if 'user_id' not in session:
        return {"status": "user not logged in"}
    session['product_id'] = request.form['product_id']
    return {"status": "successfully selected product"}

@app.route('/customer/add_to_cart', methods=['POST'])
def customer_add_to_cart():
    if 'user_id' not in session:
        return {"status": "user not logged in"}
    user_id = session['user_id']
    design_id = session['design_id']
    product_id = session['product_id']
    cur = mysql.connection.cursor()
    if 'cart_id' not in session:
        query = f"""
            SELECT cart_id FROM ImaginInk.carry WHERE customer_id = {user_id};
        """
        cur.execute(query)
        cart_id = cur.fetchone()
        session['cart_id'] = cart_id[0]
    cart_id = session['cart_id']
    query = f"""
        INSERT INTO cart_items (cart_id, design_id, product_id) VALUES 
        ({cart_id}, {design_id}, {product_id});
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return {"status": "successfully added to cart"}

@app.route('/customer/increase_item_quantity', methods=['POST'])
def customer_increase_item_quantity():
    if 'user_id' not in session:
        return {"status": "user not logged in"}
    user_id = session['user_id']
    design_id = request.form['design_id']
    product_id = request.form['product_id']
    cur = mysql.connection.cursor()
    if 'cart_id' not in session:
        query = f"""
            SELECT cart_id FROM ImaginInk.carry WHERE customer_id = {user_id};
        """
        cur.execute(query)
        cart_id = cur.fetchone()
        session['cart_id'] = cart_id[0]
    cart_id = session['cart_id']
    query = f"""
        UPDATE cart_items
            SET quantity = quantity + 1
        WHERE cart_id = {cart_id} AND design_id = {design_id} AND product_id = {product_id};
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return {"status": "successfully increased quantity"}

@app.route('/customer/decrease_item_quantity', methods=['POST'])
def customer_decrease_item_quantity():
    if 'user_id' not in session:
        return {"status": "user not logged in"}
    user_id = session['user_id']
    design_id = request.form['design_id']
    product_id = request.form['product_id']
    cur = mysql.connection.cursor()
    if 'cart_id' not in session:
        query = f"""
            SELECT cart_id FROM ImaginInk.carry WHERE customer_id = {user_id};
        """
        cur.execute(query)
        cart_id = cur.fetchone()
        session['cart_id'] = cart_id[0]
    cart_id = session['cart_id']
    query = f"""
        UPDATE cart_items
            SET quantity = quantity - 1
        WHERE cart_id = {cart_id} AND design_id = {design_id} AND product_id = {product_id};
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return {"status": "successfully decreased quantity"}

@app.route('/customer/place_order', methods=['POST'])
def customer_place_order():
    user_id = request.json('customer_id')
    cur = mysql.connection.cursor()
    if 'cart_id' not in session:
        query = f"""
            SELECT cart_id FROM ImaginInk.carry WHERE customer_id = {user_id};
        """
        cur.execute(query)
        cart_id = cur.fetchone()
        session['cart_id'] = cart_id[0]
    cart_id = session['cart_id']
    query = f"""
        SELECT total_items FROM cart WHERE cart_id = {cart_id};
    """
    cur.execute(query)
    total_items = cur.fetchone()
    if total_items[0] == 0:
        return jsonify({"status": "cart is empty"}), 400
    date = str(datetime.now().date())
    delivery_date = str(datetime.now().date() + timedelta(days=4))
    query = f"""
        INSERT INTO ImaginInk.order(order_date, delivery_date) VALUES
        ('{date}', '{delivery_date}');
        INSERT INTO checkout(order_id, cart_id) VALUES
        (LAST_INSERT_ID(), {cart_id});
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return jsonify({"status": "successfully placed order"}), 200

@app.route('/customer/logout')
def customer_logout():
    session.pop('user_id', None)
    return {"status": "successfully logged out"}
    
@app.route('/artist/signup', methods=['POST'])
def artist_signup():
    user_details = request.form
    email_id = user_details['email']
    password = user_details['password']
    username = user_details['username']
    full_name = user_details['full_name']
    payment_method = user_details['payment_method']
    date = str(datetime.now().date())
    query = f"""
        INSERT INTO ImaginInk.user (email_id, password, username, account_status, full_name, registration_date, last_login_date, account_type, payment_method) VALUES
        ('{email_id}', '{password}', '{username}', 'logged_in', '{full_name}', '{date}', '{date}', 'artist', '{payment_method}');
    """
    cur = mysql.connection.cursor()
    flag = True
    try:
        cur.execute(query)
        mysql.connection.commit()
    except (MySQLdb.Error, MySQLdb.Warning) as e:
        flag = False
    cur.close()
    if flag:
        return {"status": "successfully signed up"}
    else:
        return {"status": "email already in use"}
    
@app.route('/artist/login', methods=['POST'])
def artist_login():
    user_details = request.form
    email_id = user_details['email']
    password = user_details['password']
    query = f"""
        SELECT * FROM ImaginInk.user WHERE email_id = '{email_id}' AND password = '{password}' AND account_type = 'artist';
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
            SELECT * FROM ImaginInk.artist WHERE artist_id = {user_id};
        """
        cur = mysql.connection.cursor()
        cur.execute(query)
        artist = cur.fetchone()
        query = f"""
            SELECT * FROM ImaginInk.user WHERE user_id = {user_id};
        """
        cur.execute(query)
        user = cur.fetchone()
        cur.close()
        user_details = {
            "username": user[3],
            "email_id": user[1],
            "full_name": user[5],
            "payment_method": user[9],
            "registration_date": user[6],
        }
        return {"status": "successfully logged in", "user": user_details}
    else:
        return {"status": "invalid credentials"}
    
@app.route('/artist/view_designs')
def artist_view_designs():
    if 'user_id' not in session:
        return {"status": "user not logged in"}
    user_id = session['user_id']
    query = f"""
        SELECT * FROM design
        WHERE artist_id = {user_id};
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    designs = cur.fetchall()
    cur.close()
    user_designs = {}
    for design in designs:
        user_designs[design[0]] = {
            "title": design[2],
            "description": design[3],
            "image": design[4],
            "creation_date": design[5],
            "price": design[6],
            "sales_count": design[7],
            "views_count": design[8],
            "status": design[9]
        }
    return {"status": "successfully fetched designs", "designs": user_designs}

@app.route('/artist/upload_design', methods=['POST'])
def artist_upload_design():
    if 'user_id' not in session:
        return {"status": "user not logged in"}
    user_id = session['user_id']
    design_details = request.form
    title = design_details['title']
    description = design_details['description']
    image = design_details['image']
    price = design_details['price']
    date = str(datetime.now().date())
    query = f"""
        INSERT INTO ImaginInk.design(artist_id, title, description, image, creation_date, price) VALUES
        ({user_id}, '{title}', '{description}', '{image}', '{date}', {price});
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return {"status": "successfully uploaded design"}

@app.route('/artist/logout')
def artist_logout():
    session.pop('user_id', None)
    return {"status": "successfully logged out"}

@app.route('/admin/login', methods=['POST'])
def admin_login():
    user_details = request.form
    username = user_details['username']
    password = user_details['password']
    query = f"""
        SELECT * FROM ImaginInk.admin WHERE username = '{username}' AND password = '{password}';
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    user = cur.fetchone()
    cur.close()
    if user:
        session['admin_id'] = user[0]
        admin_id = user[0]
        return {"status": "successfully logged in"}
    else:
        return {"status": "invalid credentials"}

@app.route('/admin/view_customers')
def admin_view_customers():
    if 'admin_id' not in session:
        return {"status": "admin not logged in"}
    query = f"""
        SELECT * FROM ImaginInk.user WHERE account_type = 'customer';
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    customers = cur.fetchall()
    cur.close()
    user_customers = {}
    for customer in customers:
        user_customers[customer[0]] = {
            "email_id": customer[1],
            "username": customer[3],
            "account_status": customer[4],
            "full_name": customer[5],
            "registration_date": customer[6],
            "last_login_date": customer[7],
            "payment_method": customer[9]
        }
    query = f"""
        SELECT * FROM ImaginInk.customer;
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    addresses = cur.fetchall()
    cur.close()
    for address in addresses:
        user_customers[address[0]]["address"] = address[1]
    return {"status": "successfully fetched customers", "customers": user_customers}

@app.route('/admin/view_artists')
def admin_view_artists():
    if 'admin_id' not in session:
        return {"status": "admin not logged in"}
    query = f"""
        SELECT * FROM ImaginInk.user WHERE account_type = 'artist';
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    artists = cur.fetchall()
    cur.close()
    user_artists = {}
    for artist in artists:
        user_artists[artist[0]] = {
            "email_id": artist[1],
            "username": artist[3],
            "account_status": artist[4],
            "full_name": artist[5],
            "registration_date": artist[6],
            "last_login_date": artist[7],
            "payment_method": artist[9]
        }
    return {"status": "successfully fetched artists", "artists": user_artists}

@app.route('/admin/view_designs')
def admin_view_designs():
    if 'admin_id' not in session:
        return {"status": "admin not logged in"}
    query = f"""
        SELECT * FROM ImaginInk.design;
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    designs = cur.fetchall()
    cur.close()
    user_designs = {}
    for design in designs:
        user_designs[design[0]] = {
            "artist_id": design[1],
            "title": design[2],
            "description": design[3],
            "image": design[4],
            "creation_date": design[5],
            "price": design[6],
            "sales_count": design[7],
            "views_count": design[8],
            "status": design[9]
        }
    return {"status": "successfully fetched designs", "designs": user_designs}

@app.route('/admin/view_products')
def admin_view_products():
    if 'admin_id' not in session:
        return {"status": "admin not logged in"}
    query = f"""
        SELECT * FROM ImaginInk.product;
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    products = cur.fetchall()
    cur.close()
    user_products = {}
    for product in products:
        user_products[product[0]] = {
            "title": product[1],
            "image": product[2],
            "price": product[3],
            "sales_count": product[4],
            "dimensions": product[5]
        }
    return {"status": "successfully fetched products", "products": user_products}

# @app.route('/', methods=['GET', 'POST'])
# def home_page():
#     return render_template('home.html')

# @app.route('/customer/signup', methods=['GET', 'POST'])
# def customer_signup():
#     msg = ""
#     if request.method == 'POST':
#         user_details = request.form
#         email_id = user_details['email']
#         password = user_details['password']
#         username = user_details['username']
#         full_name = user_details['full_name']
#         payment_method = user_details['payment_method']
#         methods = {"creditcard": "Credit Card", "paytm": "PayTM", "googlepay": "Google Pay", "banktransfer": "Bank Transfer"}
#         address = user_details['address']
#         payment_method = methods[payment_method]
#         date = str(datetime.now().date())
#         query = f"""
#             INSERT INTO ImaginInk.user (email_id, password, username, account_status, full_name, registration_date, last_login_date, account_type, payment_method) VALUES
#             ('{email_id}', '{password}', '{username}', 'logged_in', '{full_name}', '{date}', '{date}', 'customer', '{payment_method}')
#         """
#         cur = mysql.connection.cursor()
#         cur.execute(query)
#         query = f"""
#             UPDATE ImaginInk.customer c
#             JOIN ImaginInk.user u ON c.customer_id = u.user_id
#             SET address = '{address}'
#             WHERE u.email_id = '{email_id}'
#             AND u.account_type = 'customer';
#         """
#         cur.execute(query)
#         mysql.connection.commit()
#         cur.close()
#     return render_template('customer/signup.html', msg=msg)

# @app.route('/artist/signup', methods=['GET', 'POST'])
# def artist_signup():
#     msg = ""
#     if request.method == 'POST':
#         user_details = request.form
#         email_id = user_details['email']
#         password = user_details['password']
#         username = user_details['username']
#         full_name = user_details['full_name']
#         payment_method = user_details['payment_method']
#         methods = {"creditcard": "Credit Card", "paytm": "PayTM", "googlepay": "Google Pay", "banktransfer": "Bank Transfer"}
#         payment_method = methods[payment_method]
#         date = str(datetime.now().date())
#         query = f"""
#             INSERT INTO ImaginInk.user (email_id, password, username, account_status, full_name, registration_date, last_login_date, account_type, payment_method) VALUES
#             ('{email_id}', '{password}', '{username}', 'logged_in', '{full_name}', '{date}', '{date}', 'artist', '{payment_method}')
#         """
#         cur = mysql.connection.cursor()
#         cur.execute(query)
#         mysql.connection.commit()
#         cur.close()
#     return render_template('artist/signup.html', msg=msg)

# @app.route('/customer/login', methods=['GET', 'POST'])
# def customer_login():
#     if request.method == 'POST':
#         user_details = request.form
#         email_id = user_details['email']
#         password = user_details['password']
#         query = f"""
#             SELECT * FROM ImaginInk.user WHERE email_id = '{email_id}' AND password = '{password}' AND account_type = 'customer';
#         """
#         cur = mysql.connection.cursor()
#         cur.execute(query)
#         user = cur.fetchone()
#         cur.close()
#         if user:
#             if user[3] == 'deleted':
#                 return render_template('customer/login.html', msg="Account has been deleted")
#             session['user_id'] = user[0]
#             user_id = user[0]
#             query = f"""
#                 SELECT * FROM ImaginInk.customer WHERE customer_id = {user_id};
#             """
#             cur = mysql.connection.cursor()
#             cur.execute(query)
#             customer = cur.fetchone()
#             query = f"""
#                 SELECT * FROM ImaginInk.user WHERE user_id = {user_id};
#             """
#             cur.execute(query)
#             user = cur.fetchone()
#             cur.close()
#             user_details = {
#                 "address": customer[1],
#                 "username": user[3],
#                 "email_id": user[1],
#                 "full_name": user[5],
#                 "payment_method": user[9],
#                 "registration_date": user[6],
#             }
#             return render_template('customer/dashboard.html', user=user_details)
#         else:
#             return render_template('customer/login.html', msg="Invalid Credentials")
#     return render_template('customer/login.html')

# @app.route('/customer/dashboard', methods=['GET', 'POST'])
# def customer_dashboard():
#     if 'user_id' not in session:
#         return redirect(url_for('customer_login'))
#     user_id = session['user_id']
#     query = f"""
#         SELECT * FROM ImaginInk.customer WHERE customer_id = {user_id};
#     """
#     cur = mysql.connection.cursor()
#     cur.execute(query)
#     customer = cur.fetchone()
#     query = f"""
#         SELECT * FROM ImaginInk.user WHERE user_id = {user_id};
#     """
#     cur.execute(query)
#     user = cur.fetchone()
#     cur.close()
#     user_details = {
#         "address": customer[1],
#         "username": user[3],
#         "email_id": user[1],
#         "full_name": user[5],
#         "payment_method": user[9],
#         "registration_date": user[6],
#     }
#     return render_template('customer/dashboard.html', user=user_details)

# # @app.route('/artist/login', methods=['GET', 'POST'])
# # def artist_login():
    
    

if __name__ == '__main__':
    app.run(host='localhost', port=8000, debug=True)