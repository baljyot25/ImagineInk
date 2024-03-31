import streamlit as st
import requests
from time import sleep
import pymysql
import pandas as pd

st.set_page_config(initial_sidebar_state="collapsed")

if __name__ == "__main__":
    if 'customer_id' not in st.session_state:
        st.error('User not logged in')
        sleep(1)
        st.switch_page("home.py")
    st.title('Order History')
    col1, col2 = st.columns([7, 1])
    with col2:
        if st.button('Back'):
            st.switch_page('pages/customerViewDesigns.py')
    st.write('---')
    response = requests.post('http://localhost:8000/customer/order_history', json={
        'customer_id': st.session_state.customer_id
    })
    response = response.json()
    if len(response['order_ids']) == 0:
        st.write('No orders yet')
    else:
        order_ids = response['order_ids']
        order_dates = response['order_dates']
        delivery_dates = response['delivery_dates']
        delivery_statuses = response['delivery_statuses']
        items = response['items']
        grand_totals = response['grand_totals']
        for i in range(0, len(order_ids)):
            st.write(f'Order Date: {order_dates[i]}')
            st.write(f'Delivery Date: {delivery_dates[i]}')
            st.write(f'Delivery Status: {delivery_statuses[i]}')
            st.write(f'Grand Total: Rs. {grand_totals[i]}')
            for j in range(0, len(items[i][0])):
                product_id = items[i][1][j]
                product_title = items[i][4][j]
                design_id = items[i][0][j]
                design_title = items[i][5][j]
                price = items[i][3][j]
                quantity = items[i][2][j]
                design_image = f'images/design/{design_id}.jpg'
                product_image = f'images/product/{product_id}.jpg'
                col1, col2, col3 = st.columns([1, 1, 2])
                with col1:
                    st.image(design_image, use_column_width=True)
                with col2:
                    st.image(product_image, use_column_width=True)
                with col3:
                    st.subheader(f'{design_title}')
                    st.write(f'Product: {product_title}')
                    st.write(f'Price: Rs. {price}')
                    st.write(f'Quantity: {quantity}')
                    st.write('---')
            st.write('---')