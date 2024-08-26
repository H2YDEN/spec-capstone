const pool = require("../util/database");

const reviewController = {
  getReviewsByProductId: (req, res) => {
    const productId = req.params.productId;

    const query = `
      SELECT pr.ReviewID, pr.ProductID, pr.UserID, pr.PublishDate, pr.StarRating, pr.DescriptionText, u.Username
      FROM productreview pr
      JOIN users u ON pr.UserID = u.UserID
      WHERE pr.ProductID = ?;
    `;

    pool.query(query, [productId], (error, results) => {
      if (error) {
        console.error("Error fetching reviews by product ID:", error);
        return res.status(500).send("Failed to fetch reviews.");
      }

      res.json(results);
    });
  },

  getReviewsByStoreId: (req, res) => {
    const storeId = req.params.storeId;

    const query = `
      SELECT u.Username, s.StarRating, s.DescriptionText
      FROM storereview s
      JOIN users u ON s.UserID = u.UserID
      WHERE s.StoreID = ? ;
    `;

    pool.query(query, [storeId], (error, results) => {
      if (error) {
        console.error("Error fetching reviews by store ID:", error);
        return res.status(500).send("Failed to fetch reviews.");
      }

      res.json(results);
    });
  },

  addNewProductReview: (req, res) => {
    const { starRating, descriptionText } = req.body;
    const productId = req.params.productId;
    const userId = req.user.UserID;

    console.log("Logged user id:", userId);
    console.log("Incoming data:", {
      productId,
      starRating,
      descriptionText,
      userId,
    });

    if (!productId || !starRating || !descriptionText || !userId) {
      return res.status(400).json({ message: "Missing required fields." });
    }

    const query = `
      INSERT INTO productreview (ProductID, UserID, StarRating, DescriptionText, PublishDate)
      VALUES (?, ?, ?, ?, NOW());
    `;

    pool.query(
      query,
      [productId, userId, starRating, descriptionText],
      (error, results) => {
        if (error) {
          console.error("Error adding product review:", error);
          return res.status(500).json({ message: "Failed to add review." });
        }
        res.status(201).json({
          ReviewID: results.insertId,
          ProductID: productId,
          UserID: userId,
          StarRating: starRating,
          DescriptionText: descriptionText,
          PublishDate: new Date(),
        });
      }
    );
  },

  addNewStoreReview: (req, res) => {
    const { starRating, descriptionText } = req.body;
    const storeId = req.params.storeId;
    const userId = req.user.UserID;

    console.log("Incoming data:", {
      storeId,
      starRating,
      descriptionText,
      userId,
    });

    if (!storeId || !starRating || !descriptionText || !userId) {
      return res.status(400).json({ message: "Missing required fields." });
    }

    const query = `
      INSERT INTO storereview (StoreID, UserID, StarRating, DescriptionText, PublishDate)
      VALUES (?, ?, ?, ?, NOW());
    `;

    pool.query(
      query,
      [storeId, userId, starRating, descriptionText],
      (error, results) => {
        if (error) {
          console.error("Error adding store review:", error);
          return res.status(500).json({ message: "Failed to add review." });
        }
        res.status(201).json({
          ReviewID: results.insertId,
          StoreID: storeId,
          UserID: userId,
          StarRating: starRating,
          DescriptionText: descriptionText,
          PublishDate: new Date(),
        });
      }
    );
  },
};

module.exports = reviewController;
