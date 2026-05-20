## Project Name 🎵
**MusicShop** — мобильное iOS-приложение музыкального салона.

## Description
MusicShop — это мобильное приложение для просмотра каталога компакт-дисков, поиска альбомов по названию, исполнителю или жанру, навигации по карте к ближайшему магазину и управления списком избранных альбомов. Приложение поддерживает авторизацию пользователей с разграничением ролей (менеджер / покупатель). Данные хранятся в SQLite, настройки пользователя — в UserDefaults. Интерфейс реализован на SwiftUI с архитектурой MVVM.

**Ключевые возможности:**
- Авторизация и регистрация пользователей
- Каталог CD с пролистыванием жестами (свайп)
- Поиск с debounce и историей запросов
- Карта магазинов с определением ближайшего
- Список избранного
- Локализация: русский, английский, белорусский

## Installation

### Требования
- macOS 14.0+
- Xcode 16+
- iOS Simulator iPhone 15 / iPhone 16 (iOS 17+)
- Реальное устройство iPhone с iOS 17+

### Шаги установки

```bash
# 1. Клонировать репозиторий
git clone https://github.com/Ksenia-Avdeevich/tpmp-gr13a-lab9-Avdeevich-Kravchenko
cd MusicShop

# 2. Открыть проект в Xcode
open MusicShop/MusicShop.xcodeproj

# 3. Выбрать симулятор или устройство
# Product → Destination → iPhone 16

# 4. Запустить (Cmd + R)
```

> При первом запуске автоматически создаётся база данных SQLite и заполняется демо-данными (10 альбомов).

### Тестовые данные

| Логин | Пароль    | Роль     |
|-------|-----------|----------|
| admin | admin123  | manager  |

## Usage

1. Запустить приложение -> экран авторизации
2. Войти (`admin` / `admin123`) или зарегистрировать нового пользователя
3. **Каталог** — листать альбомы свайпом влево/вправо, фильтровать по жанрам, открывать детали тапом
4. **Поиск** — вводить название альбома, исполнителя или жанр
5. **Карта** — видеть магазины в Минске, нажать «Ближайший магазин» для поиска
6. **Профиль** — сменить язык, тёмную тему, выйти из аккаунта

### Запуск тестов

```bash
# Unit тесты
xcodebuild test -project MusicShop/MusicShop.xcodeproj \
  -scheme MusicShop \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:MusicShopTests

# UI тесты
xcodebuild test -project MusicShop/MusicShop.xcodeproj \
  -scheme MusicShop \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:MusicShopUITests
```

## Project Structure

```
Repo/
├── MusicShop/
│   ├── App/
│   │   ├── MusicShopApp.swift        # Точка входа @main
│   │   └── ContentView.swift         # Корневое представление
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Product.swift
│   │   ├── Store.swift
│   │   └── CartItem.swift
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift
│   │   ├── CatalogViewModel.swift
│   │   ├── SearchViewModel.swift
│   │   └── MapViewModel.swift
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   └── RegisterView.swift
│   │   ├── Catalog/
│   │   │   ├── CatalogView.swift
│   │   │   ├── ProductCardView.swift
│   │   │   └── ProductDetailView.swift
│   │   ├── Search/
│   │   │   └── SearchView.swift
│   │   ├── Map/
│   │   │   └── StoreMapView.swift
│   │   ├── Profile/
│   │   │   └── ProfileView.swift
│   │   └── MainTabView.swift
│   ├── Services/
│   │   ├── DatabaseService.swift     # SQLite CRUD
│   │   └── UserDefaultsService.swift # Настройки
│   └── Resources/
│       ├── Extensions.swift
│       ├── ru.lproj/Localizable.strings
│       ├── en.lproj/Localizable.strings
│       └── be.lproj/Localizable.strings
├── MusicShopTests/                   # Unit-тесты (XCTest)
│   ├── AuthViewModelTests.swift
│   ├── CatalogViewModelTests.swift
│   ├── DatabaseServiceTests.swift
│   ├── ModelTests.swift
│   ├── SearchViewModelTests.swift
│   └── UserDefaultsServiceTests.swift
├── MusicShopUITests/                 # UI-тесты
│   └── MusicShopUITests.swift
└── .github/
    └── workflows/
        └── ci.yml                    # GitHub Actions CI
```

## Architecture

Архитектура **MVVM** (Model-View-ViewModel):

- **Model**: `User`, `Product`, `Store`, `CartItem` — чистые структуры данных
- **ViewModel**: `AuthViewModel`, `CatalogViewModel`, `SearchViewModel`, `MapViewModel` — бизнес-логика, `@Published` свойства
- **View**: SwiftUI-представления, подписаны на ViewModel через `@StateObject` / `@EnvironmentObject`
- **Service**: `DatabaseService` (SQLite3), `UserDefaultsService`

## Contributing

| Участник | Роль | Задачи |
|----------|------|--------|
| Ксения Авдеевич | Менеджер проекта / Проектировщик | Kanban-доска (GitHub Projects), UML-диаграммы (Use Case, классов, последовательности, развёртывания), макеты Figma, wiki, схема БД, README, локализация |
| Кравченко Ирина | Разработчик / Тестировщик | Код приложения (Swift/SwiftUI), DatabaseService, ViewModels, Unit-тесты, UI-тесты, GitHub Actions CI/CD, GitHub Pages |

**Группа 13а, ТПМП 2025–2026**
