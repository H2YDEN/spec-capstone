import { useState, useEffect, useContext } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import AuthContext from "../store/authContext";

const Home = () => {
  const navigate = useNavigate();
  const { state } = useContext(AuthContext);
  const [products, setProducts] = useState([]);
  const [stores, setStores] = useState({});
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [cartItems, setCartItems] = useState([]);
  const [totalPrice, setTotalPrice] = useState(0);
  const [error, setError] = useState("");
  const productsPerPage = 5;
  const cartItemsPerPage = 8;
  const [cartCurrentPage, setCartCurrentPage] = useState(1);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const productsResponse = await axios.get("/products");
        setProducts(productsResponse.data);

        const storeIds = Array.from(
          new Set(productsResponse.data.map((product) => product.StoreID))
        );

        const storePromises = storeIds.map((storeId) =>
          axios.get(`/stores/${storeId}`)
        );

        const storeResponses = await Promise.all(storePromises);
        const storeData = storeResponses.reduce((acc, response, index) => {
          acc[storeIds[index]] = response.data.storeName;
          return acc;
        }, {});

        setStores(storeData);
      } catch (error) {
        console.error("Error fetching products or stores:", error);
      }
    };

    fetchProducts();
  }, []);

  const fetchCartItems = async () => {
    try {
      const response = await axios.get("/cart", {
        headers: {
          Authorization: state.token,
        },
      });
      setCartItems(response.data);
    } catch (error) {
      console.error("Error fetching cart items:", error);
      setError("Failed to fetch cart items.");
    }
  };

  const handleCheckout = async () => {
    try {
      const response = await axios.post(
        "/cart/validate",
        {},
        {
          headers: {
            Authorization: state.token,
          },
        }
      );
      const { isValid } = response.data;

      if (isValid) {
        navigate("/checkout");
      } else {
        alert("Cart quantity exceeds stock quantity. Please adjust quantity.");
      }
    } catch (error) {
      console.error("Error validating cart stock:", error);
      alert("An error occurred while validating the cart.");
    }
  };

  useEffect(() => {
    if (state.token) {
      fetchCartItems();
    }
  }, [state.token]);

  const handleAddToCart = async (productId) => {
    try {
      const response = await axios.post(
        "/cart/items",
        { productId },
        {
          headers: {
            Authorization: state.token,
          },
        }
      );

      const newTotalPrice = parseFloat(response.data.totalPrice) || 0;
      setTotalPrice(newTotalPrice);

      await fetchCartItems();
    } catch (error) {
      console.error("Error adding to cart:", error);
    }
  };

  const filteredProducts = searchQuery
    ? products.filter((product) => {
        if (product.ProductName && product.ProductDescription) {
          return (
            product.ProductName.toLowerCase().includes(
              searchQuery.toLowerCase()
            ) ||
            product.ProductDescription.toLowerCase().includes(
              searchQuery.toLowerCase()
            )
          );
        }
        return false;
      })
    : products;

  const indexOfLastProduct = currentPage * productsPerPage;
  const indexOfFirstProduct = indexOfLastProduct - productsPerPage;
  const currentProducts = filteredProducts.slice(
    indexOfFirstProduct,
    indexOfLastProduct
  );

  const handleSearchChange = (e) => {
    setSearchQuery(e.target.value);
    setCurrentPage(1);
  };

  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  const pageNumbers = [];
  for (
    let i = 1;
    i <= Math.ceil(filteredProducts.length / productsPerPage);
    i++
  ) {
    pageNumbers.push(i);
  }

  const cartIndexOfLastItem = cartCurrentPage * cartItemsPerPage;
  const cartIndexOfFirstItem = cartIndexOfLastItem - cartItemsPerPage;
  const currentCartItems = cartItems.slice(
    cartIndexOfFirstItem,
    cartIndexOfLastItem
  );

  const cartPageNumbers = [];
  for (let i = 1; i <= Math.ceil(cartItems.length / cartItemsPerPage); i++) {
    cartPageNumbers.push(i);
  }

  const mappedProducts = currentProducts.map((product) => {
    return (
      <div key={product.ProductID} className="product-card">
        <div className="product-image">
          <img
            src={product.ProductImage || "https://via.placeholder.com/150"}
            alt={product.ProductName}
          />
        </div>
        <div className="product-info">
          <h2>
            <a
              href={`/reviews/products/${product.ProductID}`}
              className="product-link"
            >
              {product.ProductName}
            </a>
          </h2>
          <p>
            <a
              href={`/reviews/stores/${product.StoreID}`}
              className="store-link"
            >
              {stores[product.StoreID] || "Unknown Store"}
            </a>
          </p>
          <h4>Price: ${product.Price}</h4>
          <p>Description: {product.ProductDescription}</p>
          <div className="button-container">
            <button
              className="add-to-cart-btn"
              onClick={() => handleAddToCart(product.ProductID)}
            >
              Add to Cart
            </button>
          </div>
        </div>
      </div>
    );
  });

  const handleAdjustQuantity = async () => {
    try {
      const response = await axios.post(
        "/cart/adjust-quantities",
        {},
        {
          headers: {
            Authorization: state.token,
          },
        }
      );

      console.log("Quantities adjusted successfully.");
      console.log("Updated Total Price:", response.data.totalPrice);

      const newTotalPrice = parseFloat(response.data.totalPrice) || 0;
      setTotalPrice(newTotalPrice);
      await fetchCartItems();
    } catch (error) {
      console.error("Error adjusting quantities:", error);
      alert("An error occurred while adjusting quantities.");
    }
  };

  const renderCartItems = () => {
    if (!cartItems || cartItems.length === 0) {
      return <p>Your cart is empty</p>;
    }

    return (
      <div className="cart-container">
        <h2 className="cart-title">Cart</h2>
        {currentCartItems.map((item) => {
          const product = products.find((p) => p.ProductID === item.ProductID);

          if (!product) {
            return (
              <div key={item.ProductID} className="cart-item">
                <p>Product not found</p>
              </div>
            );
          }

          return (
            <div key={item.ProductID} className="cart-item">
              <img
                src={product.ProductImage || "https://via.placeholder.com/100"}
                alt={product.ProductName}
                style={{ maxWidth: "50px" }}
              />
              <div className="cart-item-text">
                <p>{product.ProductName}</p>
                <p>Price: ${product.Price}</p>
                <p>Quantity: {item.Quantity || 0}</p>
              </div>
            </div>
          );
        })}
        <div className="cart-pagination">
          {cartPageNumbers.map((number) => (
            <button
              key={number}
              onClick={() => setCartCurrentPage(number)}
              className={cartCurrentPage === number ? "active" : ""}
            >
              {number}
            </button>
          ))}
        </div>
        <div className="cart-summary">
          <h3>Total: ${totalPrice.toFixed(2)}</h3>
        </div>
        <button className="checkout-btn" onClick={handleCheckout}>
          Checkout
        </button>
        <button className="checkout-btn" onClick={handleAdjustQuantity}>
          Adjust Quantity
        </button>
      </div>
    );
  };

  return (
    <main>
      <div className="search-bar">
        <input
          type="text"
          placeholder="Search products..."
          value={searchQuery}
          onChange={handleSearchChange}
        />
      </div>
      <div className="content">
        <main className="products-container">{mappedProducts}</main>
        <div className="cart-container">{renderCartItems()}</div>
      </div>
      <div className="pagination">
        {pageNumbers.map((number) => (
          <button
            key={number}
            onClick={() => handlePageChange(number)}
            className={currentPage === number ? "active" : ""}
          >
            {number}
          </button>
        ))}
      </div>
    </main>
  );
};

export default Home;
