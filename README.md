# Структура проекта

fitman-mvp1-deepseek/
├── README.md
├── backend/
│   ├── pubspec.yaml
│   ├── dart_frog.yaml
│   ├── bin/
│   │   └── server.dart
│   ├── db/
│   │   ├── database.dart
│   │   └── migrations/
│   ├── routes/
│   │   └── api/
│   │       ├── auth/
│   │       │   ├── login.dart
│   │       │   └── register.dart
│   │       ├── users/
│   │       │   └── index.dart
│   │       ├── training/
│   │       │   └── plans.dart
│   │       ├── schedule/
│   │       │   └── index.dart
│   │       └── chat/
│   │           ├── messages.dart
│   │           └── send.dart
│   ├── models/
│   │   ├── user.dart
│   │   └── training_plan.dart
│   └── middleware/
│       └── auth_middleware.dart
├── frontend/
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   └── training_plan.dart
│   │   ├── services/
│   │   │   └── api_service.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── client_dashboard.dart
│   │   │   ├── trainer_dashboard.dart
│   │   │   ├── schedule_screen.dart
│   │   │   └── chat_screen.dart
│   │   ├── widgets/
│   │   │   └── common_widgets.dart
│   │   └── utils/
│   │       └── constants.dart
│   └── assets/
│       └── images/
├── database/
│   └── setup.sql
├── docs/
│   └── SETUP.md
└── scripts/
    ├── start_backend.sh
    └── start_frontend.sh
	
# Фитнес-менеджер (FitMan) - MVP 1.0

Система автоматизации процессов фитнес-центра для малых залов.

## 🚀 Возможности

- Управление пользователями (Клиенты, Тренеры, Администраторы)
- Планы тренировок и их назначение
- Расписание занятий
- Учет калорий и прогресса
- Чат между тренером и клиентом
- Базовые дашборды

## 🛠 Технологии

### Backend
- Dart Frog (Dart)
- PostgreSQL
- JWT аутентификация

### Frontend
- Flutter (Dart)
- Riverpod для управления состоянием
- Go Router для навигации

## 📦 Установка

### Предварительные требования
- Dart SDK 3.0+
- Flutter SDK 3.0+
- PostgreSQL 15+

### Быстрый старт

1. Клонируйте репозиторий:
```bash
git clone https://github.com/RashitIbatullin/fitman-mvp1-deepseek.git
cd fitman-mvp1-deepseek