
import datetime
import streamlit as st
import requests
from time import sleep
import pymysql
st.set_page_config(initial_sidebar_state="collapsed")

def view_cart():
    if 'customer_id' not in st.session_state:
        st.error('User not logged in')
        sleep(1)
        st.switch_page("home.py")

    st.title('Cart')
    response = requests.post('http://localhost:8000/customer/cart', json={
        'customer_id': st.session_state.customer_id
    })
    col1, col2 = st.columns([4, 1])
    with col2:
        if st.button('View Designs'):
            st.switch_page("pages/customerViewDesigns.py")
    button_values = {}
    response = response.json()
    if response['total_price'] == 0:
        st.write('Cart is empty')
        st.write('---')
    else:
        for i in range(0, len(response['product_ids'])):
            design_id = response['design_ids'][i]
            design_name = response['design_titles'][i]
            product_id = response['product_ids'][i]
            product_name = response['product_titles'][i]
            price = response['prices'][i]
            design_image = f'images/design/{design_id}.jpg'
            product_image = f'images/product/{product_id}.jpg'
            quantity = response['quantities'][i]
            col1, col2, col3 = st.columns([1, 1, 2])
            with col1:
                st.image(design_image, use_column_width=True)
            with col2:
                st.image(product_image, use_column_width=True)
            with col3:
                st.subheader(f'{design_name}')
                st.write(f'Product: {product_name}')
                st.write(f'Price: Rs. {price}')
                st.write(f'Quantity: {quantity}')
                col4, col5, col6 = st.columns([1, 1, 5])
                with col4:
                    key = f"decrease_{product_id}_{design_id}"
                    button_values[key] = st.button("\-", key=key)
                with col5:
                    key = f"increase_{product_id}_{design_id}"
                    button_values[key] = st.button("\+", key=key)
                st.write('---')
        for key, value in button_values.items():
            if value:
                action, product_id, design_id = key.split('_')
                response = requests.post('http://localhost:8000/customer/change_item_quantity', json={
                    'customer_id': st.session_state.customer_id,
                    'product_id': product_id,
                    'design_id': design_id,
                    'action': action
                })
                response = response.json()
                if response['status'] == 'successfully change quantity':
                    st.success('Quantity updated successfully')
                st.switch_page("pages/customerViewCart.py")
        st.subheader(f'Cart Total: Rs. {response["total_price"]}')
        st.write('---')
        if st.button('Proceed to Checkout'):
            response = requests.post('http://localhost:8000/customer/place_order', json={
                'customer_id': st.session_state.customer_id
            })
            response = response.json()
            date = str(datetime.datetime.now().date() + datetime.timedelta(days=4))
            st.success('Order placed successfully')
            st.success('Estimated delivery date: ' + date)
            sleep(1)
            # redirect('view_designs')
            st.switch_page("pages/customerViewDesigns.py")


if __name__ == '__main__':
    view_cart()
    if st.button('Logout'):
        response = requests.post('http://localhost:8000/customer/logout', json={
            'customer_id': st.session_state['customer_id']
        })
        del st.session_state['customer_id']
        st.success('Logged out successfully')
        sleep(1)
        st.switch_page('home.py')