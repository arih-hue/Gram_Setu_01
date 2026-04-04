const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Standard Authentication
router.post('/register', authController.register);
router.post('/login', authController.login);

// Profile CRUD
router.put('/update', authController.updateProfile);
router.delete('/delete', authController.deleteProfile);

module.exports = router;
