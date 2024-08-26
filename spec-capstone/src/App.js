import { Routes, Route, Navigate } from "react-router-dom";
import "./App.css";

import Header from "./components/Header";
import Home from "./components/Home";
import Auth from "./components/Auth";
import Form from "./components/Form";
import Profile from "./components/Profile";
import Reviews from "./components/Reviews";
import Checkout from "./components/Checkout";
import Seller from "./components/Seller";
import { useContext } from "react";
import AuthContext from "./store/authContext";

const App = () => {
  const { state } = useContext(AuthContext);

  return (
    <div className="app">
      <Header />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route
          path="/auth"
          element={!state.token ? <Auth /> : <Navigate to="/" />}
        />
        <Route
          path="/form"
          element={state.token ? <Form /> : <Navigate to="/" />}
        />
        <Route
          path="/profile"
          element={state.token ? <Profile /> : <Navigate to="/" />}
        />
        <Route path="/reviews/products/:productId" element={<Reviews />} />
        <Route path="/reviews/stores/:storeId" element={<Reviews />} />
        <Route
          path="/checkout"
          element={state.token ? <Checkout /> : <Navigate to="/" />}
        />
        <Route
          path="/seller-page"
          element={state.token ? <Seller /> : <Navigate to="/" />}
        />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </div>
  );
};

export default App;
