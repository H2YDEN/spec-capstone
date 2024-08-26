import { useState, useContext, useEffect } from "react";
import axios from "axios";
import AuthContext from "../store/authContext";
import { useNavigate } from "react-router-dom";
import "../App.css";

const Checkout = () => {
  const { state } = useContext(AuthContext);
  const navigate = useNavigate();
  const [cardNumber1, setCardNumber1] = useState("");
  const [cardNumber2, setCardNumber2] = useState("");
  const [cardNumber3, setCardNumber3] = useState("");
  const [cardNumber4, setCardNumber4] = useState("");
  const [cardName, setCardName] = useState("");
  const [streetName, setStreetName] = useState("");
  const [city, setCity] = useState("");
  const [stateUS, setState] = useState("");
  const [street, setStreet] = useState("");
  const [zipCode, setZipCode] = useState("");
  const [error, setError] = useState("");
  const [totalPrice, setTotalPrice] = useState(0);

  useEffect(() => {
    const fetchCartTotalPrice = async () => {
      try {
        const response = await axios.get("/cart/total", {
          headers: {
            Authorization: state.token,
          },
        });
        const fetchedTotalPrice = parseFloat(response.data.totalPrice);
        if (!isNaN(fetchedTotalPrice)) {
          setTotalPrice(fetchedTotalPrice);
        } else {
          throw new Error("Invalid total price value");
        }
      } catch (error) {
        console.error("Error fetching cart total price:", error);
        setError("An error occurred while fetching the total price.");
      }
    };

    fetchCartTotalPrice();
  }, [state.token]);

  const handleCheckout = (e) => {
    e.preventDefault();
    setError("");

    console.log("State:", state);

    const userId = state.userId;
    if (!userId) {
      setError("User ID is missing." + userId);
      return;
    }
    console.debug("User ID:", userId);
    console.debug("Card Number (Last 4 Digits):", cardNumber4.slice(-4));
    console.debug("Card Holder Name:", cardName);
    console.debug("Street Name:", streetName);
    console.debug("City:", city);
    console.debug("State:", stateUS);
    console.debug("Zip Code:", zipCode);

    axios
      .post(
        "/cart/validate",
        {},
        {
          headers: {
            Authorization: state.token,
          },
        }
      )
      .then((validateResponse) => {
        console.debug("Validation Response:", validateResponse.data);
        const { isValid } = validateResponse.data;

        if (isValid) {
          const lastFourDigits = cardNumber4.slice(-4);

          return axios.post(
            "/cart/checkout",
            {
              userId,
              lastFourDigits,
              cardHolderName: cardName,
              streetName,
              city,
              stateUS,
              zipCode,
            },
            {
              headers: {
                Authorization: state.token,
              },
            }
          );
        } else {
          alert("Cart Quantity exceeds Stock Quantity");
          return Promise.reject("Cart Quantity exceeds Stock Quantity");
        }
      })
      .then(() => {
        navigate("/checkout-confirmation");
      })
      .catch((error) => {
        console.error("Error during checkout:", error);
        if (error.response) {
          console.error("Response data:", error.response.data);
          console.error("Response status:", error.response.status);
          console.error("Response headers:", error.response.headers);
        } else if (error.request) {
          console.error("Request data:", error.request);
        } else {
          console.error("Error message:", error.message);
        }
        setError("An error occurred during checkout.");
      });
  };

  return (
    <div className="checkout-form">
      <h2>Checkout</h2>
      {error && <p className="error-message">{error}</p>}
      <form onSubmit={handleCheckout}>
        <div className="form-group">
          <label>Card Number:</label>
          <div className="card-number-group">
            <input
              type="number"
              value={cardNumber1}
              onChange={(e) => setCardNumber1(e.target.value)}
              placeholder="1234"
              required
            />
            <input
              type="number"
              value={cardNumber2}
              onChange={(e) => setCardNumber2(e.target.value)}
              placeholder="5678"
              required
            />
            <input
              type="number"
              value={cardNumber3}
              onChange={(e) => setCardNumber3(e.target.value)}
              placeholder="9012"
              required
            />
            <input
              type="number"
              value={cardNumber4}
              onChange={(e) => setCardNumber4(e.target.value)}
              placeholder="3456"
              required
            />
          </div>
        </div>
        <div className="form-group">
          <label>Card Name:</label>
          <input
            type="text"
            value={cardName}
            onChange={(e) => setCardName(e.target.value)}
            placeholder="John Doe"
            required
          />
        </div>
        <div className="form-group">
          <label>Street Name:</label>
          <input
            type="text"
            value={streetName}
            onChange={(e) => setStreetName(e.target.value)}
            placeholder="123 Main St"
            required
          />
        </div>
        <div className="form-group">
          <label>City:</label>
          <input
            type="text"
            value={city}
            onChange={(e) => setCity(e.target.value)}
            placeholder="Cityville"
            required
          />
        </div>
        <div className="form-group">
          <label>State:</label>
          <input
            type="text"
            value={stateUS}
            onChange={(e) => setState(e.target.value)}
            placeholder="State"
            required
          />
        </div>
        <div className="form-group">
          <label>Zip Code:</label>
          <input
            type="text"
            value={zipCode}
            onChange={(e) => setZipCode(e.target.value)}
            placeholder="12345"
            required
          />
        </div>
        <div className="checkout-summary">
          <span>Total Price: ${totalPrice.toFixed(2)}</span>
          <button type="submit" className="checkout-btn">
            Submit
          </button>
        </div>
      </form>
    </div>
  );
};

export default Checkout;
