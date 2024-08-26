const pool = require("../util/database");

const storeController = {
  createStore: (req, res) => {
    const {
      storeName,
      isActive,
      establishmentDate,
      streetName,
      city,
      stateUS,
      zipCode,
    } = req.body;
    console.log(req.user.UserID + "\n");
    pool.query(
      "CALL AddNewStore(?, ?, ?, ?)",
      [req.user.UserID, isActive, storeName, establishmentDate],
      (error, results) => {
        if (error) {
          console.error("Error creating store:", error);
          return res.status(500).json({ message: error.sqlMessage });
        }

        pool.query("SELECT LAST_INSERT_ID() AS lastID", (error, results) => {
          if (error) {
            console.error("Error getting last inserted ID:", error);
            return res.status(500).json({ message: error.sqlMessage });
          }
          const storeId = results[0].lastID;

          pool.query(
            "CALL SetStoreAddress(?, ?, ?, ?, ?)",
            [storeId, streetName, city, stateUS, zipCode],
            (error, results) => {
              if (error) {
                console.error("Error setting store address:", error);
                return res.status(500).json({ message: error.sqlMessage });
              }

              res.status(201).json({
                storeName,
                isActive,
                establishmentDate,
                streetName,
                city,
                stateUS,
                zipCode,
              });
            }
          );
        });
      }
    );
  },
  getStoreName: (req, res) => {
    const storeId = req.params.storeId;

    pool.query(
      "SELECT StoreName FROM store WHERE StoreID = ?",
      [storeId],
      (error, results) => {
        if (error) {
          console.error("Error fetching store name:", error);
          return res.status(500).json({ message: "Error fetching store name" });
        }

        if (results.length === 0) {
          return res.status(404).json({ message: "Store not found" });
        }

        const storeName = results[0].StoreName;
        res.json({ storeName });
      }
    );
  },

  getStoresByUserId: (req, res) => {
    const userId = req.user.UserID;
    console.log("Fetching stores for user ID:", userId);

    pool.query(
      "SELECT StoreID, StoreName FROM store WHERE OwnerID = ?",
      [userId],
      (error, results) => {
        if (error) {
          console.error("Error fetching stores:", error);
          return res.status(500).json({ message: "Error fetching stores" });
        }

        console.log("Fetched store data:", results);
        res.status(200).json(results);
      }
    );
  },
};

module.exports = storeController;
