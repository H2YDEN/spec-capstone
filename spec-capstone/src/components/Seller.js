import { useState, useEffect, useContext } from "react";
import axios from "axios";
import "./Seller.css";
import AuthContext from "../store/authContext";

const Seller = () => {
  const [transactions, setTransactions] = useState([]);
  const [stores, setStores] = useState([]);
  const [products, setProducts] = useState([]);
  const [productId, setProductId] = useState("");
  const [endDate, setEndDate] = useState("");
  const [discountedPrice, setDiscountedPrice] = useState("");
  const [error, setError] = useState(null);
  const { state } = useContext(AuthContext);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const headers = {
          Authorization: state.token,
        };

        const transactionsResponse = await axios.get(
          `/seller/transactions/${state.userId}`,
          { headers }
        );
        setTransactions(transactionsResponse.data);

        const storesResponse = await axios.get(
          `/seller/stores/${state.userId}`,
          { headers }
        );
        setStores(storesResponse.data);

        const productsResponse = await axios.get(
          `/seller/products/${state.userId}`,
          { headers }
        );
        setProducts(productsResponse.data);
      } catch (error) {
        console.error("Error fetching data:", error);
      }
    };

    if (state.token) {
      fetchData();
    }
  }, [state.userId, state.token]);

  const handleCreateCoupon = async () => {
    try {
      const headers = {
        Authorization: state.token,
      };

      const response = await axios.post(
        "/seller/create-coupon",
        {
          productId,
          endDate,
          discountedPrice,
        },
        { headers }
      );

      if (response.status === 200) {
        alert("Coupon created successfully!");
        setProductId("");
        setEndDate("");
        setDiscountedPrice("");
      }
    } catch (error) {
      setError("Error creating coupon: " + error.message);
    }
  };

  return (
    <div className="seller-page">
      <section className="coupon-section">
        <h1>Seller Information</h1>
        <div>
          <input
            type="number"
            placeholder="Product ID"
            value={productId}
            onChange={(e) => setProductId(e.target.value)}
          />
          <input
            type="date"
            placeholder="End Date"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
          />
          <input
            type="number"
            placeholder="Discounted Price"
            value={discountedPrice}
            onChange={(e) => setDiscountedPrice(e.target.value)}
          />
          <button className="create-coupon-button" onClick={handleCreateCoupon}>
            Create Coupon
          </button>
          {error && <p className="error">{error}</p>}
        </div>
      </section>
      <div className="column column-left">
        <h2>Transactions</h2>
        <ul>
          {transactions.map((transaction) => (
            <li key={transaction.TransactionID}>
              <strong>Transaction ID:</strong> {transaction.TransactionID}
              <br />
              <strong>Product:</strong> {transaction.ProductName}
              <br />
              <strong>Quantity:</strong> {transaction.Quantity}
              <br />
              <strong>Price:</strong> ${transaction.PriceAtTheTime}
            </li>
          ))}
        </ul>
      </div>
      <div className="column column-center">
        <h2>Stores</h2>
        <ul>
          {stores.map((store) => (
            <li key={store.StoreID}>
              <strong>Store ID:</strong> {store.StoreID}
              <br />
              <strong>Store Name:</strong> {store.StoreName}
            </li>
          ))}
        </ul>
      </div>
      <div className="column column-right">
        <h2>Products</h2>
        <ul>
          {products.map((product) => (
            <li key={product.ProductID}>
              <strong>Product ID:</strong> {product.ProductID}
              <br />
              <strong>Product Name:</strong> {product.ProductName}
              <br />
              <strong>Price:</strong> ${product.Price}
              <br />
              <strong>Stock Quantity:</strong> {product.StockQuantity}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default Seller;
