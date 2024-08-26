const pool = require("../util/database");

const checkoutController = {
  checkout: (req, res) => {
    const {
      userId,
      lastFourDigits,
      cardHolderName,
      streetName,
      city,
      stateUS,
      zipCode,
    } = req.body;

    let missingFields = [];

    if (!userId) missingFields.push("userId");
    if (!lastFourDigits) missingFields.push("lastFourDigits");
    if (!cardHolderName) missingFields.push("cardHolderName");
    if (!streetName) missingFields.push("streetName");
    if (!city) missingFields.push("city");
    if (!stateUS) missingFields.push("stateUS");
    if (!zipCode) missingFields.push("zipCode");

    if (missingFields.length > 0) {
      return res
        .status(400)
        .json({ message: `Missing fields: ${missingFields.join(", ")}` });
    }

    pool.query(
      "CALL Checkout(?, ?, ?, ?, ?, ?, ?)",
      [
        userId,
        lastFourDigits,
        cardHolderName,
        streetName,
        city,
        stateUS,
        zipCode,
      ],
      (error) => {
        if (error) {
          console.error("Error executing stored procedure:", error);
          return res.status(500).json({ message: "Checkout failed" });
        }

        res.status(200).json({ message: "Checkout successful" });
      }
    );
  },
};

module.exports = checkoutController;
