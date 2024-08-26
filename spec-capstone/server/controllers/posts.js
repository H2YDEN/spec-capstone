const pool = require("../util/database");

const productController = {
  getAllProducts: (req, res) => {
    pool.query("SELECT * FROM product", (error, results) => {
      if (error) {
        console.error("Error fetching products:", error);
        res.status(500).json({ message: "Error fetching products" });
      } else {
        res.json(results);
      }
    });
  },

  getProductById: (req, res) => {
    const productId = req.params.productId;
    pool.query(
      "SELECT * FROM product WHERE ProductID = ?",
      [productId],
      (error, results) => {
        if (error) {
          console.error("Error fetching product:", error);
          res.status(500).json({ message: "Error fetching product" });
        } else if (results.length === 0) {
          res.status(404).json({ message: "Product not found" });
        } else {
          res.json(results[0]);
        }
      }
    );
  },

  createProduct: (req, res) => {
    const {
      storeId,
      productName,
      productPrice,
      productDescription,
      productImage,
      stockQuantity,
    } = req.body;

    const currentDate = new Date();
    const releaseDate = currentDate.toISOString().slice(0, 10);
    console.log(req.user.UserID + "\n");
    pool.query(
      "CALL AddNewProduct(?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        storeId,
        req.user.UserID,
        true,
        productPrice,
        productName,
        productDescription,
        productImage,
        stockQuantity,
        releaseDate,
      ],
      (error, results) => {
        if (error) {
          console.error("Error creating product:", error);
          res.status(500).json({ message: "Error creating product" });
        } else {
          res.status(201).json({
            ProductID: results.insertId,
            storeId,
            productName,
            productPrice,
            productDescription,
            productImage,
            stockQuantity,
            releaseDate,
          });
        }
      }
    );
  },

  updateProduct: (req, res) => {
    const productId = req.params.productId;
    const {
      storeId,
      productName,
      productPrice,
      description,
      imageUrl,
      stockQuantity,
      releaseDate,
    } = req.body;

    pool.query(
      "UPDATE product SET StoreID = ?, Price = ?, ProductName = ?, ProductDescription = ?, ProductImage = ?, StockQuantity = ?, ReleaseDate = ? WHERE ProductID = ?",
      [
        storeId,
        productPrice,
        productName,
        description,
        imageUrl,
        stockQuantity,
        releaseDate,
        productId,
      ],
      (error, results) => {
        if (error) {
          console.error("Error updating product:", error);
          res.status(500).json({ message: "Error updating product" });
        } else if (results.affectedRows === 0) {
          res.status(404).json({ message: "Product not found" });
        } else {
          res.json({ message: "Product updated successfully" });
        }
      }
    );
  },

  deleteProduct: (req, res) => {
    const productId = req.params.productId;
    pool.query(
      "DELETE FROM product WHERE ProductID = ?",
      [productId],
      (error, results) => {
        if (error) {
          console.error("Error deleting product:", error);
          res.status(500).json({ message: "Error deleting product" });
        } else if (results.affectedRows === 0) {
          res.status(404).json({ message: "Product not found" });
        } else {
          res.json({ message: "Product deleted successfully" });
        }
      }
    );
  },
};

module.exports = productController;
