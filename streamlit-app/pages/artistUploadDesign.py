import streamlit as st
import requests
from time import sleep

st.set_page_config(initial_sidebar_state="collapsed")

if __name__ == '__main__':
    if 'artist_id' not in st.session_state:
        st.error('User not logged in')
        sleep(1)
        st.switch_page("home.py")
    st.title('Upload Design')
    col1, col2 = st.columns([7, 1])
    with col2:
        if st.button('Back'):
            st.switch_page("pages/artistDashboard.py")
    st.write('---')
    design_title = st.text_input('Design Title', max_chars=45)
    design_description = st.text_area('Design Description', max_chars=100)
    design_image = st.file_uploader('Upload Design Image', type=['jpg'], accept_multiple_files=False)
    design_price = st.number_input('Design Price', min_value=1)
    if st.button('Upload'):
        if design_title == '':
            st.error('Title cannot be empty.')
        elif design_image is None:
            st.error('Image cannot be empty.')
        elif design_price < 1:
            st.error('Price cannot be less than 1.')
        else:
            response = requests.post('http://localhost:8000/artist/upload_design', json={
                'artist_id': st.session_state.artist_id,
                'title': design_title,
                'description': design_description,
                'price': design_price
            })
            response = response.json()
            if response['status'] == 'design uploaded':
                design_id = response['design_id']
                with open(f'images/design/{design_id}.jpg', 'wb') as f:
                    f.write(design_image.read())
                st.success('Design uploaded successfully!')
                sleep(1)
                st.switch_page("pages/artistDashboard.py")
            else:
                st.error('Failed to upload design')
                sleep(1)
                st.switch_page("pages/artistUploadDesign.py")