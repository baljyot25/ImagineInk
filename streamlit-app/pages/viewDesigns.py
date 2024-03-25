import streamlit as st
import requests
from time import sleep

st.set_page_config(initial_sidebar_state="collapsed")

def view_designs():
    if "customer_id" not in st.session_state:
        st.error("User not logged in")
        return

    st.title('Designs')

    try:
        response = requests.post('http://localhost:8000/customer/view_designs')
        response = response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching designs: {e}")
        return  # Exit function if API request fails

    # Add button for cart option
    if st.button('Cart'):
        # Add cart functionality here, such as displaying items in the cart and total price
        st.switch_page("pages/viewCart.py")

    for i in range(len(response['design_ids'])):
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

            # Create a unique key for each button
            button_key = f'select_design_{design_id}'
            if st.button('Select Design', key=button_key):
                selected_design_id = design_id
                st.success(f'Design {design_title} selected (ID: {design_id})')

                # Trigger switch_page when button is clicked
                st.switch_page("pages/product.py")

        st.write('---')  # Separator

if __name__ == '__main__':
    view_designs()
