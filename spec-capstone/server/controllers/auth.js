require("dotenv").config({ path: "../.env" });
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const pool = require("../util/database");
const SECRET = process.env.SECRET;

const createToken = (username, id) => {
  return jwt.sign({ username: username, UserID: id }, SECRET, {
    expiresIn: "2 days",
  });
};

const authController = {
  login: (req, res) => {
    const { username, password } = req.body;

    pool.query(
      "CALL VerifyLogin(?, ?, @isValidLogin)",
      [username, password],
      (error, results) => {
        if (error) {
          console.error("Error during login:", error);
          return res.status(500).send("Failed to log in.");
        }

        pool.query("SELECT @isValidLogin", (error, results) => {
          if (error) {
            console.error("Error fetching isValidLogin:", error);
            return res.status(500).send("Failed to log in.");
          }

          if (results[0].isValidLogin === 0) {
            return res.status(401).send("Invalid credentials");
          }

          pool.query(
            "SELECT * FROM users WHERE Username = ?",
            [username],
            (error, results) => {
              if (error) {
                console.error("Error during login:", error);
                return res.status(500).send("Failed to log in.");
              }
              if (results.length > 0) {
                const foundUser = results[0];
                const token = createToken(foundUser.Username, foundUser.UserID);
                const exp = Date.now() + 1000 * 60 * 60 * 48;

                res.status(200).send({
                  username: foundUser.Username,
                  userId: foundUser.UserID,
                  token,
                  exp: exp,
                });
              } else {
                res.status(401).send("User does not exist.");
              }
            }
          );
        });
      }
    );
  },

  register: (req, res) => {
    const { username, password, email, securityQuestion, securityAnswer } =
      req.body;

    pool.query(
      "CALL AddNewUser(?, ?, ?, ?, ?, ?, ?)",
      [true, username, password, email, securityQuestion, securityAnswer, null],
      (error, results) => {
        if (error) {
          console.error("Error creating user:", error);
          return res.status(500).json({ message: error.sqlMessage });
        }
        pool.query(
          "SELECT * FROM users WHERE Username = ?",
          [username],
          (error, results) => {
            if (error) {
              console.error("Error during registration:", error);
              return res.status(500).send("Failed to register.");
            }
            if (results.length > 0) {
              const foundUser = results[0];
              const token = createToken(foundUser.Username, foundUser.UserID);
              const exp = Date.now() + 1000 * 60 * 60 * 48;

              res.status(200).send({
                userId: foundUser.UserID,
                username: foundUser.Username,
                password: password,
                email: email,
                securityQuestion: securityQuestion,
                securityAnswer: securityAnswer,
                token,
                exp: exp,
              });
            } else {
              res.status(401).send("User does not exist.");
            }
          }
        );
      }
    );
  },

  fetchSecurityQuestion: (req, res) => {
    const { username } = req.body;

    pool.query(
      "SELECT SecurityQ FROM users WHERE Username = ?",
      [username],
      (error, results) => {
        if (error) {
          console.error("Error fetching security question:", error);
          return res.status(500).send("Failed to fetch security question.");
        }

        if (results.length === 0) {
          return res.status(404).send("User not found.");
        }

        const securityQuestion = results[0].SecurityQ;

        res.status(200).json({ securityQuestion });
      }
    );
  },

  verifySecurityAnswer: (req, res) => {
    const { username, securityAnswer } = req.body;

    pool.query(
      "SELECT SecurityQAnswer FROM users WHERE Username = ?",
      [username],
      (error, results) => {
        if (error) {
          console.error("Error verifying security answer:", error);
          return res.status(500).send("Failed to verify security answer.");
        }

        if (results.length === 0) {
          return res.status(404).send("User not found.");
        }

        const user = results[0];

        if (securityAnswer === user.SecurityQAnswer) {
          res.status(200).send("Security answer verified!");
        } else {
          res.status(401).send("Incorrect security answer.");
        }
      }
    );
  },

  resetPassword: (req, res) => {
    const { username, newPassword } = req.body;

    pool.query(
      "SELECT * FROM users WHERE Username = ?",
      [username],
      (error, results) => {
        if (error) {
          console.error("Error resetting password:", error);
          return res.status(500).send("Failed to reset password.");
        }

        if (results.length === 0) {
          return res.status(404).send("User not found.");
        }

        const user = results[0];

        pool.query(
          "UPDATE users SET LoginPassword = ? WHERE UserID = ?",
          [newPassword, user.UserID],
          (error, results) => {
            if (error) {
              console.error("Error resetting password:", error);
              return res.status(500).send("Failed to reset password.");
            }
            res.status(200).send("Password reset successfully!");
          }
        );
      }
    );
  },

  fetchUsernameByEmail: (req, res) => {
    const { email } = req.body;

    pool.query(
      "SELECT Username FROM users WHERE Email = ?",
      [email],
      (error, results) => {
        if (error) {
          console.error("Error fetching username:", error);
          return res.status(500).send("Failed to fetch username.");
        }

        if (results.length === 0) {
          return res.status(404).send("Email not found.");
        }

        const username = results[0].Username;

        res.status(200).json({ username });
      }
    );
  },
};

module.exports = authController;
