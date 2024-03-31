import streamlit as st
import requests
from time import sleep
import pandas as pd
import numpy as np
import streamlit.components.v1 as components

st.set_page_config(initial_sidebar_state="collapsed")

def view_designs():
    if "customer_id" not in st.session_state:
        st.error("User not logged in")
        sleep(1)
        st.switch_page('home.py')

    st.title('Designs')

    response = requests.post('http://localhost:8000/customer/view_designs')
    response = response.json()

    col1, col2, col3 = st.columns([2, 5, 1])
    with col1:
        if st.button('Past Orders'):
            st.switch_page('pages/customerViewHistory.py')
    with col3:
        if st.button('Cart'):
            st.switch_page("pages/customerViewCart.py")
            
    tag_list = response['tag_list']
    search = st.selectbox('Filter by Tag', [''] + tag_list)

    for i in range(len(response['design_ids'])):
        design_id = response['design_ids'][i]
        design_title = response['design_titles'][i]
        design_price = response['design_prices'][i]
        design_description = response['design_descriptions'][i]
        # design_tags = pd.DataFrame([[np.array(response['design_tags'][i])]])
        design_tags = ", ".join(response['design_tags'][i])
        path_to_image = f'images/design/{design_id}.jpg'

        if search and search not in design_tags:
            continue
        
        col1, col2 = st.columns([1, 3])
        with col1:
            st.image(path_to_image, use_column_width=True)
        with col2:
            st.subheader(f'{design_title}')
            st.write(f'{design_description}')
            st.write(f'Tags: {design_tags}')
            st.write(f'Price: Rs. {design_price}')

            button_key = f'select_design_{design_id}'
            if st.button('Select Design', key=button_key):
                st.session_state.design_id = design_id
                st.success(f'Design {design_title} selected (ID: {design_id})')

                st.switch_page("pages/customerViewProducts.py")
            
    st.write('---')

if __name__ == '__main__':
    view_designs()
    if st.button('Logout'):
        response = requests.post('http://localhost:8000/customer/logout', json={
            'customer_id': st.session_state['customer_id']
        })
        del st.session_state['customer_id']
        st.success('Logged out successfully')
        sleep(1)
        st.switch_page('home.py')