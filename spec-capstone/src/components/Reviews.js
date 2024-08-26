import { useState, useEffect, useContext } from "react";
import axios from "axios";
import { useParams } from "react-router-dom";

import AuthContext from "../store/authContext";

const Reviews = () => {
  const { state } = useContext(AuthContext);
  const { productId, storeId } = useParams();
  const [reviews, setReviews] = useState([]);
  const [starRating, setStarRating] = useState("");
  const [description, setDescription] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchReviews = async () => {
      try {
        let url;
        if (productId) {
          url = `/products/${productId}/reviews`;
        } else if (storeId) {
          url = `/stores/${storeId}/reviews`;
        }

        if (url) {
          const response = await axios.get(url);
          setReviews(response.data);
        }
      } catch (error) {
        console.error("Error fetching reviews:", error);
      }
    };

    fetchReviews();
  }, [productId, storeId]);

  const handleReviewSubmit = async (e) => {
    e.preventDefault();
    setError("");
    try {
      let url;
      if (productId) {
        url = `/products/${productId}/reviews`;
      } else if (storeId) {
        url = `/stores/${storeId}/reviews`;
      }

      if (url) {
        const response = await axios.post(
          url,
          { starRating, descriptionText: description },
          {
            headers: {
              Authorization: state.token,
            },
          }
        );

        const newReview = response.data;
        setReviews((prevReviews) => [newReview, ...prevReviews]);
        setStarRating("");
        setDescription("");
      }
    } catch (error) {
      console.error("Error submitting review:", error);
      setError(
        "An error occurred while submitting your review. Please try again."
      );
    }
  };

  const renderReviews = () => {
    return reviews.map((review, index) => (
      <div key={index} className="review">
        <p>
          <strong>{review.Username}</strong>: ({review.StarRating} / 5 Stars){" "}
          {review.DescriptionText}
        </p>
      </div>
    ));
  };

  return (
    <div className="reviews-container">
      <h2>{productId ? "Product Reviews" : "Store Reviews"}</h2>
      {renderReviews()}
      <div className="review-form">
        <h3>Write a Review</h3>
        {error && <p className="error-message">{error}</p>}{" "}
        <form onSubmit={handleReviewSubmit}>
          <input
            type="number"
            min="0"
            max="5"
            step="0.1"
            placeholder="Star Rating (0.0 - 5.0)"
            value={starRating}
            onChange={(e) => setStarRating(e.target.value)}
            required
          />
          <textarea
            placeholder="Description"
            rows="4"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            required
          />
          <button type="submit">Submit Review</button>
        </form>
      </div>
    </div>
  );
};

export default Reviews;
