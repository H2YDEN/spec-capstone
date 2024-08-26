require("dotenv").config({ path: "../.env" });
const express = require("express");
const cors = require("cors");
const authController = require("./controllers/auth");
const productController = require("./controllers/posts");
const storeController = require("./controllers/stores");
const userController = require("./controllers/users");
const cartController = require("./controllers/cart");
const reviewController = require("./controllers/reviews");
const schedulesController = require("./controllers/schedules");
const checkoutController = require("./controllers/checkout");
const profileController = require("./controllers/profile");
const sellerController = require("./controllers/seller");

const { isAuthenticated } = require("./middleware/isAuth");

const app = express();
const PORT = 4005;

app.use(express.json());
app.use(cors());

app.post("/register", authController.register);
app.post("/login", authController.login);
app.post("/forgot-password", authController.fetchSecurityQuestion);
app.post("/forgot-password-submit", authController.verifySecurityAnswer);
app.post("/reset-password", authController.resetPassword);
app.post("/forgot-username", authController.fetchUsernameByEmail);

app.get("/products", productController.getAllProducts);
app.get(
  "/products/:productId",
  isAuthenticated,
  productController.getProductById
);
app.post("/products", isAuthenticated, productController.createProduct);
app.put(
  "/products/:productId",
  isAuthenticated,
  productController.updateProduct
);
app.delete(
  "/products/:productId",
  isAuthenticated,
  productController.deleteProduct
);

app.get("/stores", isAuthenticated, storeController.getStoresByUserId);
app.get(
  "/stores/:storeId/schedule",
  isAuthenticated,
  schedulesController.getStoreSchedule
);
app.post("/stores", isAuthenticated, storeController.createStore);
app.get("/stores/:storeId", storeController.getStoreName);
app.get("/stores/:storeId/reviews", reviewController.getReviewsByStoreId);
app.post(
  "/stores/:storeId/reviews",
  isAuthenticated,
  reviewController.addNewStoreReview
);

app.get(
  "/users/:userId/purchased-products",
  isAuthenticated,
  profileController.getPurchasedProducts
);
app.put(
  "/users/edit-profile",
  isAuthenticated,
  userController.updateUserProfile
);

app.get("/products/:productId/reviews", reviewController.getReviewsByProductId);
app.post(
  "/products/:productId/reviews",
  isAuthenticated,
  reviewController.addNewProductReview
);

app.get("/cart", isAuthenticated, cartController.getCartItems);
app.post("/cart/items", isAuthenticated, cartController.addItemToCart);
app.post("/cart/validate", isAuthenticated, cartController.validateCartStock);
app.post(
  "/cart/adjust-quantities",
  isAuthenticated,
  cartController.adjustCartQuantities
);
app.get("/cart/total", isAuthenticated, cartController.getCartTotal);
app.post("/cart/checkout", isAuthenticated, checkoutController.checkout);
app.post(
  "/checkout-confirmation",
  isAuthenticated,
  checkoutController.checkout
);

app.post(
  "/schedules/add",
  isAuthenticated,
  schedulesController.addStoreSchedule
);
app.delete(
  "/schedules/delete",
  isAuthenticated,
  schedulesController.deleteScheduleDay
);

app.get(
  "/seller/transactions/:userId",
  isAuthenticated,
  sellerController.getSellerTransactions
);
app.get(
  "/seller/stores/:userId",
  isAuthenticated,
  sellerController.getSellerStores
);
app.get(
  "/seller/products/:userId",
  isAuthenticated,
  sellerController.getSellerProducts
);

app.post(
  "/seller/create-coupon",
  isAuthenticated,
  sellerController.createCoupon
);

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
