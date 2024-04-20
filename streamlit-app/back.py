from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_mysqldb import MySQL
from flask_session import Session
import MySQLdb.cursors
import re
from datetime import datetime, timedelta
import sys
import os

app = Flask(__name__)

app.secret_key = os.urandom(24)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'password'
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
        user_id = user[0]
        cur = mysql.connection.cursor()
        query = f"""
            UPDATE ImaginInk.user
            SET account_status = 'logged_in'
            WHERE user_id = {user_id};
        """
        cur.execute(query)
        mysql.connection.commit()
        cur.close()
        return jsonify({"status": "successfully logged in",
                        "user_id": user_id}), 200
    else:
        return jsonify({"status": "invalid credentials"}), 200
    
@app.route('/customer/cart', methods=['POST'])
def customer_cart():
    user_details = request.json
    user_id = user_details['customer_id']
    cur = mysql.connection.cursor()
    query = f"""
        DELETE FROM ImaginInk.cart_items
        WHERE quantity = 0;
    """
    cur.execute(query)
    query = f"""
        SELECT d.design_id, d.title, p.product_id, p.title, ci.quantity, ci.price
        FROM cart_items ci
        JOIN carry c ON ci.cart_id = c.cart_id
        JOIN product p ON ci.product_id = p.product_id
        JOIN design d ON ci.design_id = d.design_id
        WHERE c.customer_id = {user_id};
    """
    cur.execute(query)
    cart = cur.fetchall()
    mysql.connection.commit()
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
    query = f"""
        SELECT * FROM design
        WHERE status = 'visible';
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    designs = cur.fetchall()
    query = f"""
        SELECT d.design_id, t.tag_name
        FROM ImaginInk.design d
        JOIN ImaginInk.design_tags dt ON d.design_id = dt.design_id
        JOIN ImaginInk.tag t ON t.tag_id = dt.tag_id
        WHERE d.status = 'visible';
    """
    cur.execute(query)
    tags = cur.fetchall()
    query = f"""
        SELECT tag_name
        FROM ImaginInk.tag
    """
    cur.execute(query)
    all_tags = cur.fetchall()
    cur.close()
    design_details = {}
    for design in designs:
        design_details[design[0]] = {
            "title": design[2],
            "description": design[3],
            "price": design[6],
            "design_id": design[0],
            "tags": []
        }
    for tag in tags:
        design_details[tag[0]]['tags'].append(tag[1])
    tag_list = []
    for tag in all_tags:
        tag_list.append(tag[0])
    design_ids = []
    design_titles = []
    design_prices = []
    design_description = []
    design_tags = []
    for design in design_details:
        design_ids.append(design)
        design_titles.append(design_details[design]['title'])
        design_prices.append(design_details[design]['price'])
        design_description.append(design_details[design]['description'])
        design_tags.append(design_details[design]['tags'])
    return jsonify({"status": "successfully fetched designs", 
                    "design_ids": design_ids, 
                    "design_titles": design_titles, 
                    "design_prices": design_prices, 
                    "design_descriptions": design_description,
                    "design_tags": design_tags,
                    "tag_list": tag_list}), 200

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

@app.route('/customer/add_to_cart', methods=['POST'])
def customer_add_to_cart():
    details = request.json
    user_id = details['customer_id']
    design_id = details['design_id']
    product_id = details['product_id']
    cur = mysql.connection.cursor()
    query = f"""
        SELECT cart_id FROM ImaginInk.carry WHERE customer_id = {user_id};
    """
    cur.execute(query)
    cart_id = cur.fetchone()[0]
    query = f"""
        SELECT * FROM cart_items
        WHERE cart_id = {cart_id} AND design_id = {design_id} AND product_id = {product_id};
    """
    cur.execute(query)
    item = cur.fetchone()
    if item:
        query = f"""
            UPDATE cart_items
                SET quantity = quantity + 1
            WHERE cart_id = {cart_id} AND design_id = {design_id} AND product_id = {product_id};
        """
        cur.execute(query)
        mysql.connection.commit()
        cur.close()
        return jsonify({"status": "successfully added to cart"}), 200
    query = f"""
        SELECT price FROM product WHERE product_id = {product_id};
    """
    cur.execute(query)
    product_price = cur.fetchone()[0]
    query = f"""
        SELECT price FROM design WHERE design_id = {design_id};
    """
    cur.execute(query)
    design_price = cur.fetchone()[0]
    price = product_price + design_price
    query = f"""
        INSERT INTO cart_items (cart_id, design_id, product_id, quantity, price) VALUES 
        ({cart_id}, {design_id}, {product_id}, 1, {price});
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return jsonify({"status": "successfully added to cart"}), 200

@app.route('/customer/change_item_quantity', methods=['POST'])
def customer_change_item_quantity():
    details = request.json
    user_id = details['customer_id']
    design_id = details['design_id']
    product_id = details['product_id']
    action = details['action']
    if action == 'increase':
        change = '+ 1'
    else:
        change = '- 1'
    cur = mysql.connection.cursor()
    query = f"""
        SELECT cart_id FROM ImaginInk.carry WHERE customer_id = {user_id};
    """
    cur.execute(query)
    cart_id = cur.fetchone()
    cart_id = cart_id[0]
    print(cart_id, file=sys.stderr)
    query = f"""
        UPDATE ImaginInk.cart_items
            SET quantity = quantity {change}
        WHERE cart_id = {cart_id} AND design_id = {design_id} AND product_id = {product_id};
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return jsonify({"status": "successfully changed quantity"}), 200

@app.route('/customer/place_order', methods=['POST'])
def customer_place_order():
    details = request.json
    user_id = details['customer_id']
    cur = mysql.connection.cursor()
    query = f"""
        SELECT cart_id FROM ImaginInk.carry WHERE customer_id = {user_id};
    """
    cur.execute(query)
    cart_id = cur.fetchone()[0]
    query = f"""
        SELECT total_items FROM ImaginInk.shopping_cart WHERE cart_id = {cart_id};
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
    """
    cur.execute(query)
    query = f"""
        INSERT INTO checkout(order_id, cart_id) VALUES
        (LAST_INSERT_ID(), {cart_id});
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return jsonify({"status": "successfully placed order"}), 200

@app.route('/customer/order_history', methods=['POST'])
def customer_order_history():
    user_id = request.json['customer_id']
    cur = mysql.connection.cursor()
    query = f"""
        UPDATE ImaginInk.order o
            SET o.delivery_status = 
                CASE
                    WHEN TO_DAYS(CURDATE()) - TO_DAYS(o.delivery_date) > -1 THEN 'delivered'
                    WHEN TO_DAYS(CURDATE()) - TO_DAYS(o.order_date) > 1 THEN 'shipped'
                    ELSE 'pending'
                END;
    """
    cur.execute(query)
    query = f"""
        SELECT o.order_id, o.order_date, o.delivery_date, o.delivery_status, ci.product_id, ci.design_id, ci.quantity, ci.price, p.title, d.title
        FROM customer c
        JOIN view_history vh ON c.customer_id = vh.customer_id
        JOIN ImaginInk.order o ON vh.order_id = o.order_id
        JOIN ImaginInk.checkout co ON o.order_id = co.order_id
        JOIN ImaginInk.shopping_cart sc ON co.cart_id = sc.cart_id
        JOIN cart_items ci ON ci.cart_id = sc.cart_id
        JOIN product p ON p.product_id = ci.product_id
        JOIN design d ON d.design_id = ci.design_id
        WHERE c.customer_id = {user_id}
        ORDER BY o.order_id DESC;
    """
    cur.execute(query)
    mysql.connection.commit()
    orders = cur.fetchall()
    cur.close()
    order_details = {}
    for order in orders:
        order_id = order[0]
        if order_id not in order_details:
            order_details[order_id] = {
                "design_ids": [],
                "product_ids": [],
                "quantities": [],
                "prices": [],
                "grand_total": 0,
                "product_titles": [],
                "design_titles": []
            }
        order_details[order_id]["order_date"] = order[1]
        order_details[order_id]["delivery_date"] = order[2]
        order_details[order_id]["delivery_status"] = order[3]
        order_details[order_id]["product_ids"].append(order[4])
        order_details[order_id]["design_ids"].append(order[5])
        order_details[order_id]["quantities"].append(order[6])
        order_details[order_id]["prices"].append(order[7])
        order_details[order_id]["product_titles"].append(order[8])
        order_details[order_id]["design_titles"].append(order[9])
        order_details[order_id]["grand_total"] += order[7]
        
    order_ids = []
    order_dates = []
    delivery_dates = []
    delivery_statuses = []
    items = []
    grand_totals = []
    for order in order_details:
        order_ids.append(order)
        order_dates.append(order_details[order]["order_date"])
        delivery_dates.append(order_details[order]["delivery_date"])
        delivery_statuses.append(order_details[order]["delivery_status"])
        curr_items = [
            order_details[order]["design_ids"],
            order_details[order]["product_ids"],
            order_details[order]["quantities"],
            order_details[order]["prices"],
            order_details[order]["product_titles"],
            order_details[order]["design_titles"]
        ]
        items.append(curr_items)
        grand_totals.append(order_details[order]["grand_total"])
    return jsonify({"status": "successfully fetched order history",
            "order_ids": order_ids,
            "order_dates": order_dates,
            "delivery_dates": delivery_dates,
            "delivery_statuses": delivery_statuses,
            "items": items,
            "grand_totals": grand_totals}), 200

@app.route('/customer/logout', methods=['POST'])
def customer_logout():
    user_id = request.json['customer_id']
    cur = mysql.connection.cursor()
    query = f"""
        UPDATE ImaginInk.user
        SET account_status = 'logged_out'
        WHERE user_id = {user_id};
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return jsonify({"status": "successfully logged out"}), 200
    
@app.route('/artist/signup', methods=['POST'])
def artist_signup():
    user_details = request.json
    email_id = user_details['email_id']
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
        return jsonify({"status": "success"}), 200
    else:
        return jsonify({"status": "email"}), 400
    
@app.route('/artist/login', methods=['POST'])
def artist_login():
    user_details = request.json
    email_id = user_details['email_id']
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
            return jsonify({"status": "account has been deleted"}), 400
        user_id = user[0]
        cur = mysql.connection.cursor()
        query = f"""
            UPDATE ImaginInk.user
            SET account_status = 'logged_in'
            WHERE user_id = {user_id};
        """
        cur.execute(query)
        mysql.connection.commit()
        cur.close()
        return jsonify({"status": "successfully logged in", "artist_id": user_id}), 200
    else:
        return jsonify({"status": "invalid credentials"}), 400
    
@app.route('/artist/dashboard', methods=['POST'])
def artist_dashboard():
    user_id = request.json['artist_id']
    cur = mysql.connection.cursor()
    query = f"""
        SELECT title, description, creation_date, price, sales_count, views_count, status
        FROM ImaginInk.design d
        WHERE d.artist_id = {user_id};
    """
    cur.execute(query)
    designs = cur.fetchall()
    cur.close()
    design_titles = []
    design_descriptions = []
    creation_dates = []
    prices = []
    sales_counts = []
    views_counts = []
    statuses = []
    revenues = []
    for design in designs:
        design_titles.append(design[0])
        design_descriptions.append(design[1])
        creation_dates.append(design[2])
        prices.append(design[3])
        sales_counts.append(design[4])
        views_counts.append(design[5])
        statuses.append(design[6])
        revenues.append(design[3] * design[4])
    return jsonify({"status": "successfully fetched designs",
                    "design_titles": design_titles,
                    "design_descriptions": design_descriptions,
                    "creation_dates": creation_dates,
                    "prices": prices,
                    "sales_counts": sales_counts,
                    "views_counts": views_counts,
                    "statuses": statuses,
                    "revenues": revenues}), 200
    
@app.route('/artist/view_designs', methods=['POST'])
def artist_view_designs():
    details = request.json
    user_id = details['artist_id']
    print(user_id, file=sys.stderr)
    query = f"""
        SELECT * 
        FROM ImaginInk.design
        WHERE artist_id = {user_id}
        AND status <> 'deleted';
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    designs = cur.fetchall()
    cur.close()
    design_ids = []
    titles = []
    descriptions = []
    creation_dates = []
    prices = []
    sales_counts = []
    views_counts = []
    statuses = []
    for design in designs:
        design_ids.append(design[0])
        titles.append(design[2])
        descriptions.append(design[3])
        creation_dates.append(design[5])
        prices.append(design[6])
        sales_counts.append(design[7])
        views_counts.append(design[8])
        statuses.append(design[9])
    print('here', file=sys.stderr)
    return jsonify({"status": "successfully fetched designs",
                    "design_ids": design_ids,
                    "titles": titles,
                    "descriptions": descriptions,
                    "creation_dates": creation_dates,
                    "prices": prices,
                    "sales_counts": sales_counts,
                    "views_counts": views_counts,
                    "statuses": statuses}), 200
    
@app.route('/artist/update_status', methods=['POST'])
def artist_update_status():
    details = request.json
    user_id = details['artist_id']
    design_id = details['design_id']
    action = details['action']
    if action == 'hide':
        status = 'hidden'
    elif action == 'show':
        status = 'visible'
    else:
        status = 'deleted'
    query = f"""
        UPDATE design
            SET status = '{status}'
        WHERE artist_id = {user_id}
        AND design_id = {design_id};
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return jsonify({"status": "successfully updated status"}), 200

@app.route('/artist/upload_design', methods=['POST'])
def artist_upload_design():
    design_details = request.json
    title = design_details['title']
    description = design_details['description']
    price = design_details['price']
    artist_id = design_details['artist_id']
    image = 'image.jpg'
    date = str(datetime.now().date())
    query = f"""
        INSERT INTO ImaginInk.design(artist_id, title, description, image, creation_date, price) VALUES
        ({artist_id}, '{title}', '{description}', '{image}', '{date}', {price});
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    mysql.connection.commit()
    query = f"""
        SELECT LAST_INSERT_ID();
    """
    cur.execute(query)
    design_id = cur.fetchone()[0]
    cur.close()
    return jsonify({"status": "design uploaded",
                    "design_id": design_id}), 200

@app.route('/artist/logout', methods=['POST'])
def artist_logout():
    user_id = request.json['artist_id']
    cur = mysql.connection.cursor()
    query = f"""
        UPDATE ImaginInk.user
        SET account_status = 'logged_out'
        WHERE user_id = {user_id};
    """
    cur.execute(query)
    mysql.connection.commit()
    cur.close()
    return jsonify({"status": "successfully logged out"}), 200

@app.route('/admin/login', methods=['POST'])
def admin_login():
    user_details = request.json
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
        return jsonify({"status": "successfully logged in", "admin_id": admin_id}), 200
    else:
        return jsonify({"status": "invalid credentials"}), 400

@app.route('/admin/view_customers', methods=['POST'])
def admin_view_customers():
    print(session, file=sys.stderr)
    # if 'admin_id' not in session:
    #     return {"status": "admin not logged in"}
    query = f"""
        SELECT * FROM ImaginInk.user WHERE account_type = 'customer';
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    customers = cur.fetchall()
    
    query = f"""
        SELECT c.customer_id, c.address, sc.grand_total
        FROM ImaginInk.customer c
        JOIN ImaginInk.carry ca ON c.customer_id = ca.customer_id
        JOIN ImaginInk.shopping_cart sc ON ca.cart_id = sc.cart_id;
    """
    cur.execute(query)
    cart_values = cur.fetchall()
    
    query = f"""
        SELECT c.customer_id, COUNT(o.order_id), SUM(sc.grand_total)
        FROM ImaginInk.customer c
        JOIN ImaginInk.view_history vh ON c.customer_id = vh.customer_id
        JOIN ImaginInk.order o ON vh.order_id = o.order_id
        JOIN ImaginInk.checkout co ON o.order_id = co.order_id
        JOIN ImaginInk.shopping_cart sc ON co.cart_id = sc.cart_id
        GROUP BY c.customer_id;
    """    
    cur.execute(query)
    view_history = cur.fetchall()
    cur.close()
    
    customer_details = {}
    for customer in customers:
        customer_details[customer[0]] = {
            "email_id": customer[1],
            "username": customer[3],
            "account_status": customer[4],
            "full_name": customer[5],
            "registration_date": customer[6],
            "last_login_date": customer[7],
            "payment_method": customer[9],
            "customer_id": customer[0],
            "order_count": 0,
            "order_volume": 0
        }
    for order in view_history:
        customer_id = order[0]
        customer_details[customer_id]['order_count'] = int(order[1])
        customer_details[customer_id]['order_volume'] = int(order[2])
    for cart in cart_values:
        customer_id = cart[0]
        customer_details[customer_id]['cart_value'] = int(cart[2])
        customer_details[customer_id]['address'] = cart[1]
    customer_ids = []
    email_ids = []
    usernames = []
    account_statuses = []
    full_names = []
    registration_dates = []
    last_login_dates = []
    payment_methods = []
    order_counts = []
    order_volumes = []
    cart_values = []
    addresses = []
    for c in customer_details:
        customer_ids.append(customer_details[c]['customer_id'])
        email_ids.append(customer_details[c]['email_id'])
        usernames.append(customer_details[c]['username'])
        account_statuses.append(customer_details[c]['account_status'])
        full_names.append(customer_details[c]['full_name'])
        registration_dates.append(customer_details[c]['registration_date'])
        last_login_dates.append(customer_details[c]['last_login_date'])
        payment_methods.append(customer_details[c]['payment_method'])
        order_counts.append(customer_details[c]['order_count'])
        order_volumes.append(customer_details[c]['order_volume'])
        cart_values.append(customer_details[c]['cart_value'])
        addresses.append(customer_details[c]['address'])
    return jsonify({"status": "successfully fetched customers", 
            "customer_ids": customer_ids,
            "email_ids": email_ids,
            "usernames": usernames,
            "account_statuses": account_statuses,
            "full_names": full_names,
            "registration_dates": registration_dates,
            "last_login_dates": last_login_dates,
            "payment_methods": payment_methods,
            "addresses": addresses,
            "order_counts": order_counts,
            "order_volumes": order_volumes,
            "cart_values": cart_values}), 200

@app.route('/admin/view_artists', methods=['POST'])
def admin_view_artists():
    query = f"""
        SELECT * FROM ImaginInk.user WHERE account_type = 'artist';
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    artists = cur.fetchall()
    
    query = f"""
        SELECT a.artist_id, SUM(d.sales_count * d.price), SUM(d.views_count), COUNT(d.design_id)
        FROM ImaginInk.artist a
        JOIN ImaginInk.design d ON a.artist_id = d.artist_id
        GROUP BY a.artist_id
    """
    cur.execute(query)
    design_data = cur.fetchall()
    
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
            "payment_method": artist[9], 
            "artist_id": artist[0],
            "total_sales": 0,
            "total_views": 0,
            "total_designs": 0
        }
    for design in design_data:
        artist_id = design[0]
        user_artists[artist_id]['total_sales'] = int(design[1])
        user_artists[artist_id]['total_views'] = int(design[2])
        user_artists[artist_id]['total_designs'] = int(design[3])
    artist_ids = []
    email_ids = []
    usernames = []
    account_statuses = []
    full_names = []
    registration_dates = []
    last_login_dates = []
    payment_methods = []
    total_sales = []
    total_views = []
    total_designs = []
    for a in user_artists:
        artist_ids.append(user_artists[a]['artist_id'])
        email_ids.append(user_artists[a]['email_id'])
        usernames.append(user_artists[a]['username'])
        account_statuses.append(user_artists[a]['account_status'])
        full_names.append(user_artists[a]['full_name'])
        registration_dates.append(user_artists[a]['registration_date'])
        last_login_dates.append(user_artists[a]['last_login_date'])
        payment_methods.append(user_artists[a]['payment_method'])
        total_sales.append(user_artists[a]['total_sales'])
        total_views.append(user_artists[a]['total_views'])
        total_designs.append(user_artists[a]['total_designs'])
    return jsonify({"status": "successfully fetched artists", 
                    "artist_ids": artist_ids,
                    "email_ids": email_ids,
                    "usernames": usernames, 
                    "account_statuses": account_statuses,
                    "full_names": full_names,
                    "registration_dates": registration_dates,
                    "last_login_dates": last_login_dates,
                    "payment_methods": payment_methods,
                    "total_sales": total_sales,
                    "total_views": total_views,
                    "total_designs": total_designs}), 200

@app.route('/admin/view_designs', methods=['POST'])
def admin_view_designs():
    query = f"""
        SELECT * FROM ImaginInk.design;
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    designs = cur.fetchall()
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
            "status": design[9],
            "design_id": design[0], 
            "tags": [],
            "total_revenue": design[7] * design[6]
        }
    query = f"""
        SELECT d.design_id, t.tag_name
        FROM ImaginInk.design d
        JOIN ImaginInk.design_tags dt ON d.design_id = dt.design_id
        JOIN ImaginInk.tag t ON t.tag_id = dt.tag_id
    """
    cur.execute(query)
    tags = cur.fetchall()
    for tag in tags:
        user_designs[tag[0]]['tags'].append(tag[1])
    cur.close()
    artist_ids = []
    design_ids = []
    design_titles = []
    design_descriptions = []
    design_prices = []
    total_sales = []
    total_views = []
    statuses = []
    tags = []
    creation_dates = []
    total_revenue = []
    for d in user_designs:
        artist_ids.append(user_designs[d]['artist_id'])
        design_ids.append(user_designs[d]['design_id'])
        design_titles.append(user_designs[d]['title'])
        design_descriptions.append(user_designs[d]['description'])
        design_prices.append(user_designs[d]['price'])
        total_sales.append(user_designs[d]['sales_count'])
        total_views.append(user_designs[d]['views_count'])
        statuses.append(user_designs[d]['status'])
        tags.append(user_designs[d]['tags'])
        creation_dates.append(user_designs[d]['creation_date'])
        total_revenue.append(user_designs[d]['total_revenue'])
    return jsonify({"status": "successfully fetched designs",
                    "artist_ids": artist_ids,
                    "design_ids": design_ids,
                    "design_titles": design_titles,
                    "design_descriptions": design_descriptions,
                    "design_prices": design_prices,
                    "total_sales": total_sales,
                    "total_views": total_views,
                    "statuses": statuses,
                    "tags": tags,
                    "creation_dates": creation_dates,
                    "total_revenue": total_revenue}), 200

@app.route('/admin/view_products', methods=['POST'])
def admin_view_products():
    query = f"""
        SELECT * FROM ImaginInk.product;
    """
    cur = mysql.connection.cursor()
    cur.execute(query)
    products = cur.fetchall()
    cur.close()
    product_ids = []
    product_titles = []
    product_prices = []
    product_sales = []
    product_revenues = []
    for product in products:
        product_ids.append(product[0])
        product_titles.append(product[1])
        product_prices.append(product[3])
        product_sales.append(product[4])
        product_revenues.append(product[4] * product[3])
    return jsonify({"status": "successfully fetched products",
                    "product_ids": product_ids,
                    "product_titles": product_titles,
                    "product_prices": product_prices,
                    "total_sales": product_sales,
                    "total_revenues": product_revenues}), 200

if __name__ == '__main__':
    app.run(host='localhost', port=8000, debug=True)