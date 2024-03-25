
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
        # redirect('customer_login')
        st.switch_page("pages/your_app.py")

    st.title('Cart')
    response = requests.post('http://localhost:8000/customer/cart', json={
        'customer_id': st.session_state.customer_id
    })
    response = response.json()
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
            # if st.button('Remove from Cart', key=product_id):
            #     st.success('Removed from cart')
                # response = requests.post('http://localhost:8000/customer/remove_from_cart', json={
                #     'customer_id': st.session_state.customer_id,
                #     'product_id': product_id
                # })
                # response = response.json()
                # if response['status'] == 'success':
                #     st.success('Removed from cart')
                # else:
                #     st.error('Failed to remove from cart')
            st.write('---')
    if len(response['product_ids']) == 0:
        st.write('Cart is empty')
    else:
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
            st.switch_page("pages/viewDesigns.py")


if __name__ == '__main__':
    view_cart()