import streamlit as st
import requests
from time import sleep
import pymysql
import pandas as pd

st.set_page_config(initial_sidebar_state="collapsed", layout='wide')

def admin_view_artists():
    st.title('Artists')
    response = requests.post('http://localhost:8000/admin/view_artists')
    response = response.json()
    data = {
        'Artist ID': response['artist_ids'],
        'Email ID': response['email_ids'],
        'Username': response['usernames'],
        'Full Name': response['full_names'],
        'Registration Date': response['registration_dates'],
        'Account Status': response['account_statuses'],
        'Last Login Date': response['last_login_dates'],
        'Payment Method': response['payment_methods'],
        'Design Count': response['total_designs'],
        'Total Sales': response['total_sales'],
        'Total Views': response['total_views']
    }
    sorting_param = st.selectbox('Sort By', ['Artist ID', 'Design Count', 'Total Sales', 'Total Views'])
    order = st.selectbox('Order', ['Ascending', 'Descending'])
    df = pd.DataFrame(data)
    df.set_index('Artist ID', inplace=True)
    if sorting_param == 'Artist ID':
        if order == 'Ascending':
            df = df.sort_values(by='Artist ID')
        else:
            df = df.sort_values(by='Artist ID', ascending=False)
    elif sorting_param == 'Design Count':
        if order == 'Ascending':
            df = df.sort_values(by='Design Count')
        else:
            df = df.sort_values(by='Design Count', ascending=False)
    elif sorting_param == 'Total Sales':
        if order == 'Ascending':
            df = df.sort_values(by='Total Sales')
        else:
            df = df.sort_values(by='Total Sales', ascending=False)
    elif sorting_param == 'Total Views':
        if order == 'Ascending':
            df = df.sort_values(by='Total Views')
        else:
            df = df.sort_values(by='Total Views', ascending=False)
    st.write(df)
    

def admin_view_customers():
    st.title('Customers')
    response = requests.post('http://localhost:8000/admin/view_customers')
    response = response.json()
    data = {
        'Customer ID': response['customer_ids'],
        'Email ID': response['email_ids'],
        'Username': response['usernames'],
        'Full Name': response['full_names'],
        'Registration Date': response['registration_dates'],
        'Account Status': response['account_statuses'],
        'Last Login Date': response['last_login_dates'],
        'Payment Method': response['payment_methods'],
        'Address': response['addresses'],
        'Order Count': response['order_counts'],
        'Order Volume': response['order_volumes'],
        'Cart Value': response['cart_values']
    }
    sorting_param = st.selectbox('Sort By', ['Customer ID', 'Order Count', 'Order Volume', 'Cart Value'])
    order = st.selectbox('Order', ['Ascending', 'Descending'])
    df = pd.DataFrame(data)
    df.set_index('Customer ID', inplace=True)
    if sorting_param == 'Customer ID':
        if order == 'Ascending':
            df = df.sort_values(by='Customer ID')
        else:
            df = df.sort_values(by='Customer ID', ascending=False)
    elif sorting_param == 'Order Count':
        if order == 'Ascending':
            df = df.sort_values(by='Order Count')
        else:
            df = df.sort_values(by='Order Count', ascending=False)
    elif sorting_param == 'Order Volume':
        if order == 'Ascending':
            df = df.sort_values(by='Order Volume')
        else:
            df = df.sort_values(by='Order Volume', ascending=False)
    elif sorting_param == 'Cart Value':
        if order == 'Ascending':
            df = df.sort_values(by='Cart Value')
        else:
            df = df.sort_values(by='Cart Value', ascending=False)
    st.write(df)
    
def admin_view_designs():
    st.title('Designs')
    response = requests.post('http://localhost:8000/admin/view_designs')
    response = response.json()
    data = {
        'Design ID': response['design_ids'],
        'Artist ID': response['artist_ids'],
        'Title': response['design_titles'],
        'Description': response['design_descriptions'],
        'Price': response['design_prices'],
        'Total Sales': response['total_sales'],
        'Total Revenue': response['total_revenue'],
        'Total Views': response['total_views'],
        'Status': response['statuses'],
        'Tags': response['tags'],
        'Creation Date': response['creation_dates']        
    }
    sorting_param = st.selectbox('Sort By', ['Design ID', 'Total Sales', 'Total Views', 'Total Revenue'])
    order = st.selectbox('Order', ['Ascending', 'Descending'])
    df = pd.DataFrame(data)
    df.set_index('Design ID', inplace=True)
    if sorting_param == 'Design ID':
        if order == 'Ascending':
            df = df.sort_values(by='Design ID')
        else:
            df = df.sort_values(by='Design ID', ascending=False)
    elif sorting_param == 'Total Sales':
        if order == 'Ascending':
            df = df.sort_values(by='Total Sales')
        else:
            df = df.sort_values(by='Total Sales', ascending=False)
    elif sorting_param == 'Total Views':
        if order == 'Ascending':
            df = df.sort_values(by='Total Views')
        else:
            df = df.sort_values(by='Total Views', ascending=False)
    elif sorting_param == 'Total Revenue':
        if order == 'Ascending':
            df = df.sort_values(by='Total Revenue')
        else:
            df = df.sort_values(by='Total Revenue', ascending=False)
    st.write(df)
    
def admin_view_products():
    st.title('Products')
    response = requests.post('http://localhost:8000/admin/view_products')
    response = response.json()
    data = {
        'Product ID': response['product_ids'],
        'Title': response['product_titles'],
        'Price': response['product_prices'],
        'Total Sales': response['total_sales'],
        'Total Revenue': response['total_revenues']
    }
    sorting_param = st.selectbox('Sort By', ['Product ID', 'Total Sales', 'Total Revenue'])
    order = st.selectbox('Order', ['Ascending', 'Descending'])
    df = pd.DataFrame(data)
    df.set_index('Product ID', inplace=True)
    if sorting_param == 'Product ID':
        if order == 'Ascending':
            df = df.sort_values(by='Product ID')
        else:
            df = df.sort_values(by='Product ID', ascending=False)
    elif sorting_param == 'Total Sales':
        if order == 'Ascending':
            df = df.sort_values(by='Total Sales')
        else:
            df = df.sort_values(by='Total Sales', ascending=False)
    elif sorting_param == 'Total Revenue':
        if order == 'Ascending':
            df = df.sort_values(by='Total Revenue')
        else:
            df = df.sort_values(by='Total Revenue', ascending=False)
    st.write(df)

if __name__ == '__main__':
    if 'admin_id' not in st.session_state:
        st.error('Admin not logged in')
        sleep(1)
        st.switch_page("home.py")
    st.title('Admin Dashboard')
    selection_param = st.selectbox('Select', ['Artists', 'Customers', 'Designs', 'Products'])
    if selection_param == 'Artists':
        admin_view_artists()
    elif selection_param == 'Customers':
        admin_view_customers()
    elif selection_param == 'Designs':
        admin_view_designs()
    elif selection_param == 'Products':
        admin_view_products()
    if st.button('Logout'):
        del st.session_state['admin_id']
        st.success('Logged out successfully')
        sleep(1)
        st.switch_page('home.py')