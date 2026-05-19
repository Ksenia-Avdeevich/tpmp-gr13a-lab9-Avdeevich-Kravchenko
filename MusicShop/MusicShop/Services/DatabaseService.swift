import Foundation
import SQLite3


private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

// MARK: - Database Service

final class DatabaseService {
    
    // MARK: - Singleton
    
    static let shared = DatabaseService()
    
    // MARK: - Properties
    
    private var db: OpaquePointer?
    private let dbFileName = "musicshop.db"
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Setup
    
    func setup() {
        openDatabase()
        createTables()
        seedDataIfNeeded()
    }
    
    private func openDatabase() {
        let fileURL = getDocumentsDirectory().appendingPathComponent(dbFileName)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database: \(String(cString: sqlite3_errmsg(db)))")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Create Tables
    
    private func createTables() {
        let createUsersTable = """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'buyer',
            created_at TEXT NOT NULL
        );
        """
        
        let createProductsTable = """
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            genre TEXT NOT NULL,
            price REAL NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 0,
            image_name TEXT NOT NULL DEFAULT 'music_placeholder',
            description TEXT DEFAULT '',
            release_year INTEGER NOT NULL DEFAULT 2024
        );
        """
        
        let createFavoritesTable = """
        CREATE TABLE IF NOT EXISTS favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (product_id) REFERENCES products(id),
            UNIQUE(user_id, product_id)
        );
        """
        
        let createCartTable = """
        CREATE TABLE IF NOT EXISTS cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (product_id) REFERENCES products(id),
            UNIQUE(user_id, product_id)
        );
        """
        
        executeUpdate(createUsersTable)
        executeUpdate(createProductsTable)
        executeUpdate(createFavoritesTable)
        executeUpdate(createCartTable)
    }
    
    // MARK: - Seed Data
    
    private func seedDataIfNeeded() {
        let countQuery = "SELECT COUNT(*) FROM products;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, countQuery, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                let count = sqlite3_column_int(stmt, 0)
                if count == 0 {
                    seedProducts()
                    seedAdminUser()
                }
            }
        }
        sqlite3_finalize(stmt)
    }
    
    private func seedProducts() {
        let products: [(String, String, String, Double, Int, String, Int)] = [
            ("The Dark Side of the Moon", "Pink Floyd", "Rock", 29.99, 15, "pink_floyd", 1973),
            ("Thriller", "Michael Jackson", "Pop", 24.99, 20, "mj_thriller", 1982),
            ("Kind of Blue", "Miles Davis", "Jazz", 32.99, 8, "miles_davis", 1959),
            ("Symphony No. 9", "Ludwig van Beethoven", "Classical", 19.99, 12, "beethoven", 1824),
            ("Random Access Memories", "Daft Punk", "Electronic", 27.99, 10, "daft_punk", 2013),
            ("To Pimp a Butterfly", "Kendrick Lamar", "Hip-Hop", 22.99, 18, "kendrick", 2015),
            ("Back in Black", "AC/DC", "Rock", 21.99, 25, "acdc", 1980),
            ("21", "Adele", "Pop", 18.99, 30, "adele_21", 2011),
            ("Kind of Blue Vol.2", "John Coltrane", "Jazz", 28.99, 6, "coltrane", 1964),
            ("Nevermind", "Nirvana", "Rock", 20.99, 22, "nirvana", 1991)
        ]
        
        for product in products {
            let sql = """
            INSERT INTO products (title, artist, genre, price, quantity, image_name, release_year)
            VALUES (?, ?, ?, ?, ?, ?, ?);
            """
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, product.0, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 2, product.1, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 3, product.2, -1, SQLITE_TRANSIENT)
                sqlite3_bind_double(stmt, 4, product.3)
                sqlite3_bind_int(stmt, 5, Int32(product.4))
                sqlite3_bind_text(stmt, 6, product.5, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(stmt, 7, Int32(product.6))
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
    }
    
    private func seedAdminUser() {
        let sql = """
        INSERT OR IGNORE INTO users (username, email, password_hash, role, created_at)
        VALUES ('admin', 'admin@musicshop.by', ?, 'manager', ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            let hash = "admin123".sha256()
            sqlite3_bind_text(stmt, 1, hash, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, ISO8601DateFormatter().string(from: Date()), -1, SQLITE_TRANSIENT)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
    
    // MARK: - User Operations
    
    func registerUser(username: String, email: String, password: String) -> User? {
        let hash = password.sha256()
        let sql = """
        INSERT INTO users (username, email, password_hash, role, created_at)
        VALUES (?, ?, ?, 'buyer', ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        sqlite3_bind_text(stmt, 1, username, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, email, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, hash, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, ISO8601DateFormatter().string(from: Date()), -1, SQLITE_TRANSIENT)
        let result = sqlite3_step(stmt)
        sqlite3_finalize(stmt)
        
        guard result == SQLITE_DONE else { return nil }
        return fetchUser(by: username)
    }
    
    func loginUser(username: String, password: String) -> User? {
        let hash = password.sha256()
        let sql = "SELECT id, username, email, password_hash, role, created_at FROM users WHERE username = ? AND password_hash = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        sqlite3_bind_text(stmt, 1, username, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, hash, -1, SQLITE_TRANSIENT)
        
        var user: User?
        if sqlite3_step(stmt) == SQLITE_ROW {
            user = userFrom(stmt: stmt)
        }
        sqlite3_finalize(stmt)
        return user
    }
    
    private func fetchUser(by username: String) -> User? {
        let sql = "SELECT id, username, email, password_hash, role, created_at FROM users WHERE username = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        sqlite3_bind_text(stmt, 1, username, -1, SQLITE_TRANSIENT)
        var user: User?
        if sqlite3_step(stmt) == SQLITE_ROW {
            user = userFrom(stmt: stmt)
        }
        sqlite3_finalize(stmt)
        return user
    }
    
    private func userFrom(stmt: OpaquePointer?) -> User {
        let id = Int(sqlite3_column_int(stmt, 0))
        let username = String(cString: sqlite3_column_text(stmt, 1))
        let email = String(cString: sqlite3_column_text(stmt, 2))
        let hash = String(cString: sqlite3_column_text(stmt, 3))
        let roleStr = String(cString: sqlite3_column_text(stmt, 4))
        let role = User.UserRole(rawValue: roleStr) ?? .buyer
        return User(id: id, username: username, email: email, passwordHash: hash, role: role)
    }
    
    // MARK: - Product Operations
    
    func fetchAllProducts() -> [Product] {
        let sql = "SELECT id, title, artist, genre, price, quantity, image_name, description, release_year FROM products ORDER BY title;"
        return fetchProducts(sql: sql)
    }
    
    func searchProducts(query: String) -> [Product] {
        let sql = """
        SELECT id, title, artist, genre, price, quantity, image_name, description, release_year
        FROM products
        WHERE title LIKE ? OR artist LIKE ? OR genre LIKE ?
        ORDER BY title;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        let like = "%\(query)%"
        sqlite3_bind_text(stmt, 1, like, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, like, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, like, -1, SQLITE_TRANSIENT)
        
        var products: [Product] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            products.append(productFrom(stmt: stmt))
        }
        sqlite3_finalize(stmt)
        return products
    }
    
    func fetchProducts(byGenre genre: String) -> [Product] {
        let sql = """
        SELECT id, title, artist, genre, price, quantity, image_name, description, release_year
        FROM products WHERE genre = ? ORDER BY title;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        sqlite3_bind_text(stmt, 1, genre, -1, SQLITE_TRANSIENT)
        var products: [Product] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            products.append(productFrom(stmt: stmt))
        }
        sqlite3_finalize(stmt)
        return products
    }
    
    func fetchFavorites(userId: Int) -> [Product] {
        let sql = """
        SELECT p.id, p.title, p.artist, p.genre, p.price, p.quantity, p.image_name, p.description, p.release_year
        FROM products p INNER JOIN favorites f ON p.id = f.product_id
        WHERE f.user_id = ? ORDER BY p.title;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        sqlite3_bind_int(stmt, 1, Int32(userId))
        var products: [Product] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            products.append(productFrom(stmt: stmt))
        }
        sqlite3_finalize(stmt)
        return products
    }
    
    func toggleFavorite(userId: Int, productId: Int) -> Bool {
        if isFavorite(userId: userId, productId: productId) {
            let sql = "DELETE FROM favorites WHERE user_id = ? AND product_id = ?;"
            var stmt: OpaquePointer?
            sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
            sqlite3_bind_int(stmt, 1, Int32(userId))
            sqlite3_bind_int(stmt, 2, Int32(productId))
            sqlite3_step(stmt)
            sqlite3_finalize(stmt)
            return false
        } else {
            let sql = "INSERT OR IGNORE INTO favorites (user_id, product_id) VALUES (?, ?);"
            var stmt: OpaquePointer?
            sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
            sqlite3_bind_int(stmt, 1, Int32(userId))
            sqlite3_bind_int(stmt, 2, Int32(productId))
            sqlite3_step(stmt)
            sqlite3_finalize(stmt)
            return true
        }
    }
    
    func isFavorite(userId: Int, productId: Int) -> Bool {
        let sql = "SELECT COUNT(*) FROM favorites WHERE user_id = ? AND product_id = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        sqlite3_bind_int(stmt, 1, Int32(userId))
        sqlite3_bind_int(stmt, 2, Int32(productId))
        var result = false
        if sqlite3_step(stmt) == SQLITE_ROW {
            result = sqlite3_column_int(stmt, 0) > 0
        }
        sqlite3_finalize(stmt)
        return result
    }
    
    // MARK: - Private Helpers
    
    private func fetchProducts(sql: String) -> [Product] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        var products: [Product] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            products.append(productFrom(stmt: stmt))
        }
        sqlite3_finalize(stmt)
        return products
    }
    
    private func productFrom(stmt: OpaquePointer?) -> Product {
        let id = Int(sqlite3_column_int(stmt, 0))
        let title = String(cString: sqlite3_column_text(stmt, 1))
        let artist = String(cString: sqlite3_column_text(stmt, 2))
        let genreStr = String(cString: sqlite3_column_text(stmt, 3))
        let genre = Product.Genre(rawValue: genreStr) ?? .rock
        let price = sqlite3_column_double(stmt, 4)
        let quantity = Int(sqlite3_column_int(stmt, 5))
        let imageName = String(cString: sqlite3_column_text(stmt, 6))
        let description = String(cString: sqlite3_column_text(stmt, 7))
        let releaseYear = Int(sqlite3_column_int(stmt, 8))
        return Product(id: id, title: title, artist: artist, genre: genre,
                       price: price, quantity: quantity, imageName: imageName,
                       description: description, releaseYear: releaseYear)
    }
    
    @discardableResult
    private func executeUpdate(_ sql: String) -> Bool {
        var errorMessage: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &errorMessage) != SQLITE_OK {
            if let msg = errorMessage { print("SQL error: \(String(cString: msg))") }
            return false
        }
        return true
    }
}
