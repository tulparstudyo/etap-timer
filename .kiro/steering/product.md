# Product Overview

Tulpar is a QR code-based screen lock system for Pardus Linux. It provides secure desktop locking with web-based authentication.

## Core Functionality

- Desktop application locks the screen and displays a QR code
- Users scan the QR code via web interface to unlock
- Session-based unlocking with configurable timeout (default: 30 minutes)
- Auto-relock after timeout expires

## User Flow

1. User registers via web interface with email, phone, and institution
2. Desktop app generates unique QR code when locked
3. User scans QR code from mobile/web to authenticate
4. Desktop unlocks for configured duration
5. System auto-locks after timeout

## Key Features

- JWT-based authentication
- Single-use, time-limited QR codes
- Institution-based user management
- Profile management (phone, institution updates)

## Target Users

Organizations using Pardus Linux that need centralized, secure screen lock management with mobile-based authentication.
