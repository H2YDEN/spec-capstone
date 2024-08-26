import { useState, useEffect, useContext } from "react";
import axios from "axios";
import AuthContext from "../store/authContext";

const Profile = () => {
  const { state } = useContext(AuthContext);

  const [products, setProducts] = useState([]);
  const [showEditProfileForm, setShowEditProfileForm] = useState(false);
  const [editUsername, setEditUsername] = useState("");
  const [editPassword, setEditPassword] = useState("");
  const [editEmail, setEditEmail] = useState("");
  const [editDateOfBirth, setEditDateOfBirth] = useState("");
  const [editStreetName, setEditStreetName] = useState("");
  const [editCity, setEditCity] = useState("");
  const [editState, setEditState] = useState("");
  const [editZipCode, setEditZipCode] = useState("");

  useEffect(() => {
    const fetchPurchasedProducts = async () => {
      try {
        const userId = state.userId;
        const response = await axios.get(
          `/users/${userId}/purchased-products`,
          {
            headers: {
              Authorization: state.token,
            },
          }
        );
        setProducts(response.data);
      } catch (error) {
        console.error("Error fetching purchased products:", error);
      }
    };

    if (state.token) {
      fetchPurchasedProducts();
    }
  }, [state.token, state.userId]);

  const handleEditProfileSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.put(
        `/users/edit-profile`,
        {
          editUsername,
          editPassword,
          editEmail,
          editDateOfBirth,
          editStreetName,
          editCity,
          editState,
          editZipCode,
        },
        {
          headers: {
            Authorization: state.token,
          },
        }
      );
      setShowEditProfileForm(false);
      alert("Profile updated successfully!");
    } catch (err) {
      console.error("Error updating profile:", err);
      alert("Error updating profile. Please try again.");
    }
  };

  const mappedProducts = products.map((product) => {
    return (
      <div key={product.TransactionID} className="product-card">
        <h2>{product.ProductName}</h2>
        <h4>Price: ${product.PriceAtTheTime}</h4>
        <p>Quantity: {product.Quantity}</p>
        <p>Transaction ID: {product.TransactionID}</p>
      </div>
    );
  });

  return (
    <main>
      <h1>Transaction History</h1>
      <button className="form-btn" onClick={() => setShowEditProfileForm(true)}>
        Edit Profile
      </button>
      {showEditProfileForm && (
        <form className="form auth-form" onSubmit={handleEditProfileSubmit}>
          <input
            className="form-input"
            placeholder="Username"
            onChange={(e) => setEditUsername(e.target.value)}
            value={editUsername}
          />
          <input
            className="form-input"
            placeholder="Password"
            type="password"
            onChange={(e) => setEditPassword(e.target.value)}
            value={editPassword}
          />
          <input
            className="form-input"
            placeholder="Email"
            onChange={(e) => setEditEmail(e.target.value)}
            value={editEmail}
          />
          <input
            className="form-input"
            type="date"
            placeholder="Date of Birth"
            onChange={(e) => setEditDateOfBirth(e.target.value)}
            value={editDateOfBirth}
          />
          <input
            className="form-input"
            placeholder="Street Name"
            onChange={(e) => setEditStreetName(e.target.value)}
            value={editStreetName}
          />
          <input
            className="form-input"
            placeholder="City"
            onChange={(e) => setEditCity(e.target.value)}
            value={editCity}
          />
          <input
            className="form-input"
            placeholder="State"
            onChange={(e) => setEditState(e.target.value)}
            value={editState}
          />
          <input
            className="form-input"
            placeholder="Zip Code"
            onChange={(e) => setEditZipCode(e.target.value)}
            value={editZipCode}
          />
          <button className="form-btn">Update Profile</button>
        </form>
      )}

      {mappedProducts.length > 0 ? (
        <div className="products-container">{mappedProducts}</div>
      ) : (
        <p>You haven't purchased any products yet!</p>
      )}
    </main>
  );
};

export default Profile;
