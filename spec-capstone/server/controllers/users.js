const pool = require("../util/database");

const userController = {
  updateUserProfile: (req, res) => {
    const {
      editUsername,
      editPassword,
      editEmail,
      editDateOfBirth,
      editStreetName,
      editCity,
      editState,
      editZipCode,
    } = req.body;
    const userId = req.user.UserID;
    console.log(userId);

    pool.query(
      "CALL SetUsername(?, ?)",
      [userId, editUsername],
      (error, results) => {
        if (error) {
          console.error("Error updating username:", error);
          return res.status(500).json({ message: "Error updating username" });
        }

        pool.query(
          "CALL SetLoginPassword(?, ?)",
          [userId, editPassword],
          (error, results) => {
            if (error) {
              console.error("Error updating password:", error);
              return res
                .status(500)
                .json({ message: "Error updating password" });
            }

            pool.query(
              "CALL SetEmail(?, ?)",
              [userId, editEmail],
              (error, results) => {
                if (error) {
                  console.error("Error updating email:", error);
                  return res
                    .status(500)
                    .json({ message: "Error updating email" });
                }
                pool.query(
                  "CALL SetDateOfBirth(?, ?)",
                  [userId, editDateOfBirth],
                  (error, results) => {
                    if (error) {
                      console.error("Error updating date of birth:", error);
                      return res
                        .status(500)
                        .json({ message: "Error updating date of birth" });
                    }
                    pool.query(
                      "CALL SetUserAddress(?, ?, ?, ?, ?)",
                      [
                        userId,
                        editStreetName,
                        editCity,
                        editState,
                        editZipCode,
                      ],
                      (error, results) => {
                        if (error) {
                          console.error("Error updating address:", error);
                          return res
                            .status(500)
                            .json({ message: "Error updating address" });
                        }
                        res
                          .status(200)
                          .json({ message: "Profile updated successfully!" });
                      }
                    );
                  }
                );
              }
            );
          }
        );
      }
    );
  },
};

module.exports = userController;
