allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    afterEvaluate {
        if (hasProperty("android")) {
            val android = extensions.getByName("android") as? com.android.build.gradle.BaseExtension
            android?.apply {
                // lStar hatasını tamamen bitirmek için tüm eklentileri SDK 36'ya zorla
                compileSdkVersion(36)
                buildToolsVersion("36.0.0")

                // Namespace eksikliği hatasını çözmek için (Özellikle Isar gibi paketlerde)
                if (namespace == null) {
                    namespace = "com.aladin.iptv.pro." + project.name.replace(":", ".").replace("-", ".")
                }
            }
        }
    }

    project.configurations.all {
        resolutionStrategy {
            // RECEIVER_EXPORTED hatasını çözmek için kütüphaneyi güncelle
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
            force("androidx.annotation:annotation:1.8.0")
        }
    }
}
