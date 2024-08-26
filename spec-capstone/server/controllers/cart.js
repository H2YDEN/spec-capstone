const pool = require("../util/database");

const cartController = {
  addItemToCart: (req, res) => {
    const { productId } = req.body;
    const userId = req.user.UserID;
    const quantity = 1;

    pool.query(
      "SELECT Quantity FROM cart WHERE UserID = ? AND ProductID = ?",
      [userId, productId],
      (error, results) => {
        if (error) {
          console.error("Error checking cart item:", error);
          return res.status(500).json({ message: "Error checking cart item" });
        }

        let query;
        let queryParams;

        if (results.length > 0) {
          query =
            "UPDATE cart SET Quantity = Quantity + ? WHERE UserID = ? AND ProductID = ?";
          queryParams = [quantity, userId, productId];
        } else {
          const dateAdded = new Date()
            .toISOString()
            .slice(0, 19)
            .replace("T", " ");
          query =
            "INSERT INTO cart (UserID, ProductID, Quantity, DateAdded) VALUES (?, ?, ?, ?)";
          queryParams = [userId, productId, quantity, dateAdded];
        }

        pool.query(query, queryParams, (error) => {
          if (error) {
            console.error("Error updating or adding item to cart:", error);
            return res
              .status(500)
              .json({ message: "Error updating or adding item to cart" });
          }

          pool.query(
            "CALL GetCartTotalPrice(?, @totalPrice);",
            [userId],
            (error) => {
              if (error) {
                console.error("Error calling stored procedure:", error);
                return res
                  .status(500)
                  .json({ message: "Error calling stored procedure" });
              }

              pool.query(
                "SELECT @totalPrice AS totalPrice;",
                (error, results) => {
                  if (error) {
                    console.error("Error fetching cart total price:", error);
                    return res
                      .status(500)
                      .json({ message: "Error fetching cart total price" });
                  }

                  const totalPrice = results[0].totalPrice;

                  res.status(200).json({
                    message: "Item added to cart successfully",
                    totalPrice,
                  });
                }
              );
            }
          );
        });
      }
    );
  },

  getCartItems: (req, res) => {
    const userId = req.user.UserID;

    pool.query(
      `SELECT c.ProductID, c.Quantity, p.ProductName, p.Price
       FROM cart c
       JOIN product p ON c.ProductID = p.ProductID
       WHERE c.UserID = ?`,
      [userId],
      (error, results) => {
        if (error) {
          console.error("Error fetching cart items:", error);
          return res
            .status(500)
            .json({ message: "Failed to fetch cart items." });
        }

        res.json(results);
      }
    );
  },

  validateCartStock: (req, res) => {
    const userId = req.user.UserID;

    pool.query("CALL ValidateCartStock(?, @is_valid);", [userId], (error) => {
      if (error) {
        console.error("Error calling stored procedure:", error);
        return res.status(500).json({ message: "Error validating cart stock" });
      }

      pool.query("SELECT @is_valid AS isValid;", (error, results) => {
        if (error) {
          console.error("Error fetching validation result:", error);
          return res
            .status(500)
            .json({ message: "Error fetching validation result" });
        }

        const isValid = results[0].isValid;
        res.status(200).json({ isValid });
      });
    });
  },

  getCartTotal: (req, res) => {
    const userId = req.user.UserID;

    pool.query("CALL GetCartTotalPrice(?, @totalPrice);", [userId], (error) => {
      if (error) {
        console.error("Error calling stored procedure:", error);
        return res
          .status(500)
          .json({ message: "Error calling stored procedure" });
      }

      pool.query("SELECT @totalPrice AS totalPrice;", (error, results) => {
        if (error) {
          console.error("Error fetching cart total price:", error);
          return res
            .status(500)
            .json({ message: "Error fetching cart total price" });
        }

        const totalPrice = results[0].totalPrice;

        res.status(200).json({
          totalPrice,
        });
      });
    });
  },

  adjustCartQuantities: (req, res) => {
    const userId = req.user.UserID;

    pool.query("CALL AdjustCartQuantities(?);", [userId], (error) => {
      if (error) {
        console.error("Error calling AdjustCartQuantities procedure:", error);
        return res
          .status(500)
          .json({ message: "Error adjusting cart quantities" });
      }

      pool.query(
        "DELETE FROM cart WHERE UserID = ? AND Quantity = 0;",
        [userId],
        (error) => {
          if (error) {
            console.error("Error deleting items with zero quantity:", error);
            return res
              .status(500)
              .json({ message: "Error deleting items with zero quantity" });
          }

          pool.query(
            `SELECT c.ProductID, c.Quantity, p.ProductName, p.Price
             FROM cart c
             JOIN product p ON c.ProductID = p.ProductID
             WHERE c.UserID = ?`,
            [userId],
            (error, cartItems) => {
              if (error) {
                console.log("Error fetching updated cart items:", error);
                return res
                  .status(500)
                  .json({ message: "Error fetching updated cart items" });
              }

              pool.query(
                "CALL GetCartTotalPrice(?, @totalPrice);",
                [userId],
                (error) => {
                  if (error) {
                    console.log(
                      "Error calling GetCartTotalPrice procedure:",
                      error
                    );
                    return res
                      .status(500)
                      .json({
                        message: "Error calling GetCartTotalPrice procedure",
                      });
                  }

                  pool.query(
                    "SELECT @totalPrice AS totalPrice;",
                    (error, results) => {
                      if (error) {
                        console.log("Error fetching cart total price:", error);
                        return res
                          .status(500)
                          .json({ message: "Error fetching cart total price" });
                      }

                      const totalPrice =
                        results[0] && results[0].totalPrice !== null
                          ? results[0].totalPrice
                          : 0;

                      res.status(200).json({
                        message:
                          "Quantities adjusted and items with zero quantity removed successfully",
                        cartItems,
                        totalPrice,
                      });
                    }
                  );
                }
              );
            }
          );
        }
      );
    });
  },
};

module.exports = cartController;
