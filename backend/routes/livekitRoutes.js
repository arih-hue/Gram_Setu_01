const express = require('express');
const router = express.Router();
const { AccessToken } = require('livekit-server-sdk');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * Generate a LiveKit Access Token for a user.
 * POST /api/livekit/token
 * Body: { roomName: "room_123" }
 */
router.post('/token', authMiddleware, async (req, res) => {
    try {
        const { roomName } = req.body;
        const participantName = req.user.name || req.user.username || 'Anonymous User';
        const participantIdentity = req.user.id || req.user._id || `user_${Math.random().toString(36).substring(7)}`;

        if (!roomName) {
            return res.status(400).json({ message: 'roomName is required' });
        }

        const apiKey = process.env.LIVEKIT_API_KEY;
        const apiSecret = process.env.LIVEKIT_API_SECRET;
        const serverUrl = process.env.LIVEKIT_URL;

        if (!apiKey || !apiSecret || !serverUrl) {
            return res.status(500).json({ message: 'LiveKit configuration is missing on server' });
        }

        const at = new AccessToken(apiKey, apiSecret, {
            identity: participantIdentity,
            name: participantName,
        });

        at.addGrant({
            roomJoin: true,
            room: roomName,
            canPublish: true,
            canSubscribe: true,
            canPublishData: true,
        });

        const token = await at.toJwt();

        res.status(200).json({
            token,
            serverUrl,
        });
    } catch (error) {
        console.error('Error generating LiveKit token:', error);
        res.status(500).json({ message: 'Failed to generate access token' });
    }
});

module.exports = router;
