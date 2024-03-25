
import streamlit as st
import requests

import datetime
from time import sleep
# import streamlit as st
st.set_page_config(initial_sidebar_state="collapsed")
# Create an expander with its content initially hidden

st.markdown(
    """
    <style>
        /* Add some padding and margin */
        .stTextInput, .stSelectbox, .stTextArea {
            margin-bottom: 15px;
            padding: 8px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        /* Style the button */
        .stButton>button {
            background-color: #4CAF50; /* Green */
            color: white;
            padding: 10px 20px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            cursor: pointer;
            border-radius: 5px;
        }
        .stButton>button:hover {
            background-color: #45a049;
        }
        /* Error message style */
        .error-text {
            color: red;
            font-size: 14px;
        }
    </style>
    """,
    unsafe_allow_html=True
)

def admin_login():
    st.title('Admin Login')
    username = st.text_input('Username', max_chars=45)
    password = st.text_input('Password', type='password', max_chars=45)
    if st.button('Login'):
        if username == '':
            st.error('Username cannot be empty.')
        elif password == '':
            st.error('Password cannot be empty.')
        else:
            response = requests.post('http://localhost:8000/customer/login', json={
                'username': username,
                'password': password
            })
            response = response.json()
            if response['status'] == 'invalid credentials':
                st.error('Invalid Username/Password')
            else:
                st.success('Login successful!')
                sleep(1)
                st.session_state.admin_id = response['admin_id']
                # redirect('admin_dashboard')

    

def customer_signup():
    st.title('Sign Up')
    st.write('Already have an account? [Login](?page=customer_login) here')
    email_id = st.text_input('Email ID', max_chars=45)
    password = st.text_input('Password', type='password', max_chars=45)
    full_name = st.text_input('Full Name', max_chars=45)
    username = st.text_input('Display Name', max_chars=45)
    payment_method = st.selectbox('Payment Method', ['Credit Card', 'PayTM', 'Google Pay', 'Bank Transfer'])
    address = st.text_area('Address', max_chars=255)
    if st.button('Signup'):
        if email_id == '':
            st.error('Email cannot be empty.')
        elif password == '':
            st.error('Password cannot be empty.')
        elif full_name == '':
            st.error('Full Name cannot be empty.')
        elif username == '':
            st.error('Display Name cannot be empty.')
        elif payment_method == '':
            st.error('Payment Method cannot be empty.')
        elif address == '':
            st.error('Address cannot be empty.')
        else:
            response = requests.post('http://localhost:8000/customer/signup', json={
                'email_id': email_id,
                'password': password,
                'full_name': full_name,
                'username': username,
                'payment_method': payment_method,
                'address': address
            })
            response = response.json()
            if response['status'] == 'email':
                st.error('Invalid Email/Email already in use')
            else:
                st.success('Signup successful!') 
                if st.button('Proceed to Login'):
                    st.empty()
                    customer_login()


def customer_login():
    st.title('Login')
    st.write('New user? [Sign Up](?page=customer_signup) here')
    email_id = st.text_input('Email ID', max_chars=45)
    password = st.text_input('Password', type='password', max_chars=45)
    if st.button('Login'):
        if email_id == '':
            st.error('Email cannot be empty.')
        elif password == '':
            st.error('Password cannot be empty.')
        else:
            response = requests.post('http://localhost:8000/customer/login', json={
                'email_id': email_id,
                'password': password
            })
            response = response.json()
            if response['status'] == 'invalid credentials':
                st.error('Invalid Email/Password')
            elif response['status'] == 'account has been deleted':
                st.error('Account has been deleted')
            else:
                st.success('Login successful!')
                sleep(1)
                # st.empty()
                st.session_state.customer_id = response['user']['user_id']
                # st.session_state.redirected_view_designs = True
                st.switch_page("pages/viewDesigns.py")
    st.write('Login as? [Admin](?page=admin_login)')
        
# def admin_login():

                
if __name__ == '__main__':

    query_params = st.query_params.get_all('page')
    if not query_params:
        customer_login()
    elif query_params[0] == 'customer_login':
        customer_login()
    elif query_params[0] == 'customer_signup':
        customer_signup()
    elif query_params[0] == 'admin_login':
        admin_login()