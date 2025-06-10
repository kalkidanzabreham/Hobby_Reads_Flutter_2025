const express = require("express")
const router = express.Router()
const authController = require("../controllers/auth.controller")
const { verifyToken } = require("../middleware/auth.middleware")

// Register a new user
router.post("/register", authController.register)

// Login user
router.post("/login", authController.login)

// Get current user profile (protected route)
router.get("/profile", verifyToken, authController.getUserProfile)

module.exports = router
