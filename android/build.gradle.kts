import org.gradle.api.publish.PublishingExtension
import org.gradle.api.publish.maven.MavenPublication
import org.gradle.kotlin.dsl.create
import org.gradle.kotlin.dsl.named

plugins {
    id("com.android.library") version "8.5.2"
    id("org.jetbrains.kotlin.android") version "1.9.24"
    id("maven-publish")
}

val pluginVersion = providers.gradleProperty("pluginVersion")
    .orElse(System.getenv("PLUGIN_VERSION") ?: "0.0.0-SNAPSHOT")

group = "com.github.bangonkali"
version = pluginVersion.get()

repositories {
    google()
    mavenCentral()
    maven("https://jitpack.io")
}

android {
    namespace = "DuckdbPlugin"
    compileSdk = 34

    defaultConfig {
        minSdk = 28
        aarMetadata {
            minCompileSdk = 28
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }
}

dependencies {
    implementation("androidx.webkit:webkit:1.6.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    compileOnly("app.tauri:tauri-android:2.9.3")
}

publishing {
    publications {
        create<MavenPublication>("release") {
            groupId = project.group.toString()
            artifactId = "duckdb-plugin"
            version = project.version.toString()
            pom {
                name = "tauri-duckdb-android"
                description = "Android DuckDB plugin for Tauri apps"
                url = "https://github.com/bangonkali/tauri-duckdb"
                licenses {
                    license {
                        name = "MIT"
                        url = "https://opensource.org/licenses/MIT"
                    }
                }
                developers {
                    developer {
                        id = "bangonkali"
                        name = "bangonkali"
                    }
                }
                scm {
                    url = "https://github.com/bangonkali/tauri-duckdb"
                    connection = "scm:git:https://github.com/bangonkali/tauri-duckdb.git"
                    developerConnection = "scm:git:ssh://git@github.com/bangonkali/tauri-duckdb.git"
                }
            }
        }
    }
}

afterEvaluate {
    extensions.configure<PublishingExtension>("publishing") {
        publications {
            named<MavenPublication>("release") {
                from(components["release"])
            }
        }
    }
}
