const pool = require("../util/database");

const sellerController = {
  getSellerTransactions: (req, res) => {
    const userId = req.params.userId;

    pool.query(
      `
      SELECT t.TransactionID, pro.ProductName, p.Quantity, p.PriceAtTheTime
      FROM transactions t
      JOIN purchases p ON t.TransactionID = p.TransactionID
      JOIN product pro ON p.ProductID = pro.ProductID
      WHERE pro.UserID = ?
    `,
      [userId],
      (error, results) => {
        if (error) {
          console.error("Error executing query", error);
          return res.status(500).json({ error: error.message });
        }
        res.json(results);
      }
    );
  },

  getSellerStores: (req, res) => {
    const userId = req.params.userId;

    pool.query(
      `
      SELECT StoreID, StoreName
      FROM store
      WHERE OwnerID = ?
    `,
      [userId],
      (error, results) => {
        if (error) {
          console.error("Error executing query", error);
          return res.status(500).json({ error: error.message });
        }
        res.json(results);
      }
    );
  },

  getSellerProducts: (req, res) => {
    const userId = req.params.userId;

    pool.query(
      `
      SELECT p.ProductID, p.ProductName, p.Price, p.StockQuantity
      FROM product p
      JOIN store s ON p.StoreID = s.StoreID
      WHERE s.OwnerID = ?
    `,
      [userId],
      (error, results) => {
        if (error) {
          console.error("Error executing query", error);
          return res.status(500).json({ error: error.message });
        }
        res.json(results);
      }
    );
  },

  createCoupon: (req, res) => {
    const { productId, endDate, discountedPrice } = req.body;

    if (!productId || !endDate || discountedPrice == null) {
      return res.status(400).json({ message: "Invalid input data" });
    }

    pool.query(
      "CALL AddNewCoupon(?, ?, ?);",
      [productId, endDate, discountedPrice],
      (error) => {
        if (error) {
          console.error("Error adding new coupon:", error);
          return res.status(500).json({ message: "Error creating coupon" });
        }

        res.status(200).json({ message: "Coupon created successfully" });
      }
    );
  },
};

module.exports = sellerController;
