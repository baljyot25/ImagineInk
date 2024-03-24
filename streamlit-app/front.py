import streamlit as st
import requests

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

def customer_signup():
    st.title('Signup')
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
                st.write('Please login to continue')
                st.write('Click [here](http://localhost:8501) to login')
                st.stop()
                
def customer_login():
    st.title('Login')
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
                st.write('Click [here](http://localhost:8501) to continue')
                st.stop()
                
if __name__ == '__main__':
    st.sidebar.title('Menu')
    menu = st.sidebar.radio('Navigation', ['Login', 'Signup'])
    if menu == 'Login':
        customer_login()
    else:
        customer_signup()