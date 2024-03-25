import streamlit as st
import requests
from time import sleep
import pymysql
st.set_page_config(initial_sidebar_state="collapsed")

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
        # product_dimension = response['product_dimensions'][i]
        path_to_image = f'images/product/{product_id}.jpg'
        col1, col2 = st.columns([1, 3])
        with col1:
            st.image(path_to_image, use_column_width=True)
        with col2:
            st.subheader(f'{product_title}')
            # st.write(f'Dimensions: {product_dimension}')
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
                st.switch_page("pages/viewDesigns.py")
            
            st.write('---')

if __name__ == '__main__':
    view_products()