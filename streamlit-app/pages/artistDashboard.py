import streamlit as st
import requests
from time import sleep
import pandas as pd

st.set_page_config(initial_sidebar_state="collapsed", layout='wide')

def display_dashboard():
    st.title('Artist Dashboard')
    response = requests.post('http://localhost:8000/artist/dashboard', json={
        'artist_id': st.session_state.artist_id
    })
    if st.button('Upload Design'):
        st.switch_page("pages/artistUploadDesign.py")
    if st.button('Manage Designs'):
        st.switch_page("pages/artistManageDesigns.py")
    response = response.json()  
    st.subheader('Artist Analytics')
    if (len(response['design_titles']) == 0):
        st.write('No designs uploaded yet')
    else:
        col1, col2, col3 = st.columns([1, 5, 1])
        with col2:
            df = pd.DataFrame({
                'Title': response['design_titles'],
                'Description': response['design_descriptions'],
                'Price': response['prices'],
                'Creation Date': response['creation_dates'],
                'Sales Count': response['sales_counts'],
                'Views Count': response['views_counts'],
                'Revenue': response['revenues'],
                'Status': response['statuses']
            })
            st.write(df)
    

if __name__ == "__main__":
    if 'artist_id' not in st.session_state:
        st.error('User not logged in')
        sleep(1)
        st.switch_page("home.py")
    display_dashboard()
    if st.button('Log Out'):
        response = requests.post('http://localhost:8000/artist/logout', json={
            'artist_id': st.session_state['artist_id']
        })
        del st.session_state['artist_id']
        st.switch_page("home.py")