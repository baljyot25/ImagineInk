import {configureStore} from '@reduxjs/toolkit';
import pizzaReducer from './components/pizzaSlice';

export const store = configureStore(
    {
        reducer: {
            pizza: pizzaReducer,
        },
    }
);
export default store;