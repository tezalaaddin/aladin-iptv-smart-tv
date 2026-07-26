package com.aladin.iptv.player.pro

import android.app.SearchManager
import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.database.MatrixCursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.net.Uri
import android.provider.BaseColumns

class AladinSearchProvider : ContentProvider() {

    private var dbHelper: DatabaseHelper? = null

    override fun onCreate(): Boolean {
        dbHelper = DatabaseHelper(context ?: return false)
        return true
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor? {
        val query = uri.lastPathSegment?.lowercase() ?: return null
        if (query == SearchManager.SUGGEST_URI_PATH_QUERY) return null

        val db = dbHelper?.readableDatabase ?: return null
        
        // Android TV Global Search expects specific columns
        val columns = arrayOf(
            BaseColumns._ID,
            SearchManager.SUGGEST_COLUMN_TEXT_1, // Title
            SearchManager.SUGGEST_COLUMN_TEXT_2, // Description
            SearchManager.SUGGEST_COLUMN_RESULT_CARD_IMAGE, // Image
            SearchManager.SUGGEST_COLUMN_INTENT_DATA // Deep link URL
        )

        val cursor = MatrixCursor(columns)

        val sql = "SELECT * FROM search_items WHERE name LIKE ? LIMIT 50"
        val dbCursor = db.rawQuery(sql, arrayOf("%$query%"))

        while (dbCursor.moveToNext()) {
            val id = dbCursor.getInt(dbCursor.getColumnIndexOrThrow("id"))
            val name = dbCursor.getString(dbCursor.getColumnIndexOrThrow("name"))
            val category = dbCursor.getString(dbCursor.getColumnIndexOrThrow("category"))
            val logo = dbCursor.getString(dbCursor.getColumnIndexOrThrow("logo"))
            val url = dbCursor.getString(dbCursor.getColumnIndexOrThrow("url"))

            cursor.addRow(arrayOf(
                id,
                name,
                category,
                logo,
                "aladin://play?url=$url"
            ))
        }
        dbCursor.close()
        return cursor
    }

    override fun getType(uri: Uri): String? = SearchManager.SUGGEST_MIME_TYPE
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0

    class DatabaseHelper(context: android.content.Context) : SQLiteOpenHelper(context, "search_index.db", null, 1) {
        override fun onCreate(db: SQLiteDatabase) {
            db.execSQL("CREATE TABLE search_items (id INTEGER PRIMARY KEY, name TEXT, category TEXT, logo TEXT, url TEXT)")
            db.execSQL("CREATE INDEX idx_name ON search_items(name)")
        }
        override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
            db.execSQL("DROP TABLE IF EXISTS search_items")
            onCreate(db)
        }
    }
}
