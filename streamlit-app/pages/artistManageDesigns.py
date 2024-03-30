import streamlit as st
import requests
from time import sleep

st.set_page_config(initial_sidebar_state="collapsed", layout='wide')

def manage_designs():
    st.title('Manage Designs')
    if st.button('Back'):
        st.switch_page("pages/artistDashboard.py")
    response = requests.post('http://localhost:8000/artist/view_designs', json={
        'artist_id': st.session_state.artist_id
    })
    response = response.json()
    if len(response['design_ids']) == 0:
        st.write('No designs uploaded yet')
    button_values = {}
    for i in range(0, len(response['design_ids'])):
        design_id = response['design_ids'][i]
        design_title = response['titles'][i]
        design_price = response['prices'][i]
        design_description = response['descriptions'][i]
        creation_date = response['creation_dates'][i]
        sales_count = response['sales_counts'][i]
        views_count = response['views_counts'][i]
        status = response['statuses'][i]
        path_to_image = f'images/design/{design_id}.jpg'
        col1, col2, col3 = st.columns([2, 3, 3])
        with col1:
            st.image(path_to_image, use_column_width=True)
        with col2:
            st.subheader(f'{design_title}')
            st.write(f'Description: {design_description}')
            st.write(f'Price: Rs. {design_price}')
            st.write(f'Uploaded On: {creation_date}')
            st.write(f'Sales: {sales_count}')
            st.write(f'Views: {views_count}')
        with col3:
            if status == 'visible':
                key = f'hide_{design_id}'
                button_values[key] = st.button('Hide design', key=key)
            else:
                key = f'show_{design_id}'
                button_values[key] = st.button('Display design', key=key)
            key = f'delete_{design_id}'
            button_values[key] = st.button('Delete design', key=key)
        st.write('---')
    for key, value in button_values.items():
        if value:
            action, design_id = key.split('_')
            response = requests.post('http://localhost:8000/artist/update_status', json={
                'artist_id': st.session_state.artist_id,
                'design_id': design_id,
                'action': action
            })
            response = response.json()
            st.switch_page("pages/artistManageDesigns.py")
            
if __name__ == "__main__":
    if 'artist_id' not in st.session_state:
        st.error('User not logged in')
        sleep(1)
        st.switch_page("home.py")
    manage_designs()