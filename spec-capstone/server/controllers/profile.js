const pool = require("../util/database");

const profileController = {
  getPurchasedProducts: (req, res) => {
    const { userId } = req.params;
    const query = `
      SELECT t.TransactionID, pro.ProductName, p.Quantity, p.PriceAtTheTime
      FROM transactions t
      JOIN purchases p ON t.TransactionID = p.TransactionID
      JOIN product pro ON p.ProductID = pro.ProductID
      WHERE t.BuyerID = ?
    `;

    pool
      .promise()
      .query(query, [userId])
      .then(([results]) => {
        res.status(200).json(results);
      })
      .catch((error) => {
        console.error(error);
        res.status(500).json({ message: "Server error" });
      });
  },
};

module.exports = profileController;
