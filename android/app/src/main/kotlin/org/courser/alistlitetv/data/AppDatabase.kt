/*
package org.courser.alistlitetv.data

import androidx.room.AutoMigration
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import org.courser.alistandroid.data.dao.ServerLogDao
import org.courser.alistlitetv.data.entities.ServerLog
import org.courser.alistlitetv.App.Companion.app

val appDb by lazy { AppDatabase.create() }

@Database(
    version = 2,
    entities = [ServerLog::class],
    autoMigrations = [
        AutoMigration(from = 1, to = 2)
    ]
)
abstract class AppDatabase : RoomDatabase() {
    abstract val serverLogDao: ServerLogDao

    companion object {
        fun create() = Room.databaseBuilder(
            app,
            AppDatabase::class.java,
            "alistandroid.db"
        )
            .allowMainThreadQueries()
            .build()
    }
}*/
