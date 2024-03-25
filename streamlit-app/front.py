import streamlit as st
import requests
from time import sleep
import pymysql

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

def connect_to_database():
    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='sm1243',
        db='imaginink',
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection

def redirect(page_name):
    query_params = {"page": page_name}
    st.query_params['page'] = [page_name]
    st.rerun()
    # st.experimental_set_query_params(**query_params)
    # st.experimental_rerun()

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
                redirect('view_designs')
                
def customer_dashboard():
    # create a sidebar with options of view designs, view orders, view profile, logout and cart
    st.sidebar.title('Dashboard')
    page = st.sidebar.radio("Go to", ["View Designs", "View Cart"])
    if page == 'View Cart':
        redirect('view_cart')
    elif page == 'View Designs':
        redirect('view_designs')

def view_designs():
    # display all designs
    # customer_dashboard()
    st.session_state.redirected_view_designs = False
    if 'customer_id' not in st.session_state:
        st.error('User not logged in')
        sleep(1)
        redirect('customer_login')
    st.title('Designs')
    response = requests.post('http://localhost:8000/customer/view_designs')
    response = response.json()
    for i in range(0, len(response['design_ids'])):
        design_id = response['design_ids'][i]
        design_title = response['design_titles'][i]
        design_price = response['design_prices'][i]
        design_description = response['design_descriptions'][i]
        path_to_image = f'images/design/{design_id}.jpg'
        col1, col2 = st.columns([1, 3])
        with col1:
            st.image(path_to_image, use_column_width=True)
        with col2:
            st.subheader(f'{design_title}')
            st.write(f'{design_description}')
            st.write(f'Price: Rs. {design_price}')
            if st.button('Select Design', key=design_id):
                st.success('Design selected')
                sleep(1)
                st.session_state.selected_design_id = 1
                view_products()
            st.write('---')
    
    
def view_products():
    # if 'customer_id' not in st.session_state:
    #     st.error('User not logged in')
    #     sleep(1)
    #     redirect('customer_login')
    # elif 'selected_design_id' not in st.session_state:
    #     st.error('Design not selected')
    #     sleep(1)
    #     redirect('view_designs')
    st.title('Products')
    response = requests.post('http://localhost:8000/customer/view_products')
    response = response.json()
    for i in range(0, len(response['product_ids'])):
        product_id = response['product_ids'][i]
        product_title = response['product_titles'][i]
        product_price = response['product_prices'][i]
        product_dimension = response['product_dimensions'][i]
        path_to_image = f'images/product/{product_id}.jpg'
        col1, col2 = st.columns([1, 3])
        with col1:
            st.image(path_to_image, use_column_width=True)
        with col2:
            st.subheader(f'{product_title}')
            st.write(f'Dimensions: {product_dimension}')
            st.write(f'Price: Rs. {product_price}')
            if st.button('Add to Cart', key=product_id):
                pass
                # response = requests.post('http://localhost:8000/customer/add_to_cart', json={
                #     'customer_id': st.session_state.customer_id,
                #     'design_id': st.session_state.selsected_design_id,
                #     'product_id': product_id
                # })
                # response = response.json()
                # if response['status'] == 'success':
                #     st.success('Added to cart')
                # else:
                #     st.error('Failed to add to cart')
            st.write('---')
    
    
def view_cart():
    # customer_dashboard()
    st.write('Cart')
    pass

if __name__ == '__main__':
    # connection = connect_to_database()
    query_params = st.query_params.get_all('page')
    if not query_params:
        customer_login()
    elif query_params[0] == 'customer_login':
        customer_login()
    elif query_params[0] == 'customer_signup':
        customer_signup()
    elif query_params[0] == 'customer_dashboard':
        customer_dashboard()
    elif query_params[0] == 'view_cart':
        view_cart()
    elif query_params[0] == 'view_designs':
        view_designs()
    elif query_params[0] == 'view_products':
        view_products()