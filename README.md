# 📱 FinPath Frontend

> Financial Wellness Companion for Underserved Communities  
> Built for the **Innovation hack 2.0 at ASU**

---

## 🌟 Overview

FinPath is a **mobile-first financial guidance app** designed to help people navigate financial independence without guidance — including:

- Recent immigrants  
- Young adults (18–25)  
- Gig workers with irregular income  

Unlike traditional financial tools, FinPath doesn’t overwhelm users with information.  
Instead, it provides:

👉 Personalized next steps  
👉 Simple, contextual explanations  
👉 Actionable financial guidance  

> “Meet me where I am financially — and show me the next step forward.”

---

## 🎯 Problem

Many users:

- Don’t know what to ask (even with AI tools)
- Feel overwhelmed by financial information
- Lack access to trusted financial guidance

FinPath solves this by acting like an **experienced friend** — guiding users step-by-step.

---

## 🚀 Features (MVP)

### ✅ Smart Onboarding
- Conversational 5–7 question flow
- Builds a personalized financial profile

### 📊 Financial Snapshot
- Clear visual dashboard:
  - 🟢 Covered areas
  - 🔴 Financial gaps

### 🎯 Prioritized Action Plan
- Exactly **3 next steps**
- Ranked by urgency
- No overwhelm

### 📚 Contextual Education
- Tap any term → simple explanation
- Learning happens in context

### 🌍 Multilingual Support
- English 🇺🇸
- Spanish 🇪🇸
- Designed for accessibility (not just translation)

### 🤖 AI Financial Assistant
- Context-aware chat
- Uses user's financial profile
- Markdown-rendered responses

---

## 🛠️ Tech Stack

### Framework
- **Flutter** (iOS & Android)
- **Dart (SDK ^3.11.4)**

### Core Packages
- **State Management:** Provider  
- **Networking:** http  
- **Secure Storage:** flutter_secure_storage  
- **Local Storage:** shared_preferences  
- **Localization:** intl + flutter_localizations  
- **Markdown Rendering:** flutter_markdown  
- **External Links:** url_launcher  

### UI
- Material Design (Flutter)
- Cupertino Icons

---

## 🧠 Key Frontend Capabilities

- Secure JWT token handling with encrypted storage
- Persistent user session management
- Context-driven UI based on financial profile
- Multilingual experience (English & Spanish)
- AI response rendering using Markdown

---

## 📂 Project Structure

```bash
lib/
│
├── core/                # Configs, constants, themes
├── services/            # API services (auth, onboarding, AI)
├── models/              # Data models
├── features/
│   ├── onboarding/      # Quiz flow
│   ├── snapshot/        # Financial dashboard
│   ├── actions/         # Action plan
│   ├── ai_chat/         # AI assistant
│   └── settings/        # Preferences & language
│
├── widgets/             # Reusable components
└── main.dart
